# == Schema Information
#
# Table name: inscripcionescuelaperiodos
#
#  id                         :bigint           not null, primary key
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  escuelaperiodo_id          :bigint           not null
#  estudiante_id              :string(255)      not null
#  grado_id                   :bigint
#  reportepago_id             :bigint
#  tipo_estado_inscripcion_id :string(255)
#
class Inscripcionescuelaperiodo < ApplicationRecord

	# Tipo Estado Inscripciones
	# ["CO", "INS", "NUEVO", "PRE", "REINC", "RES", "RET", "VAL"] 

	# ASOCIACIONES:
	has_many :inscripcionsecciones, dependent: :destroy
	accepts_nested_attributes_for :inscripcionsecciones

	has_many :secciones, through: :inscripcionsecciones, source: :seccion
	has_many :asignaturas, through: :secciones

	belongs_to :estudiante, primary_key: 'usuario_id'
	belongs_to :escuelaperiodo
	belongs_to :tipo_estado_inscripcion
	belongs_to :grado
	has_one :usuario, through: :estudiante
	has_one :escuela, through: :escuelaperiodo
	has_one :periodo, through: :escuelaperiodo

	belongs_to :reportepago, optional: true

	#CALLBACKS:
	after_save :bitacora_confirmacion_inscripcion

	# VALIDACIONES:
	validates_uniqueness_of :estudiante_id, scope: [:escuelaperiodo_id], message: 'El estudiante ya posee una inscripción en el período actual', field_name: false

	# SCOPES:
	scope :del_periodo, -> (periodo_id) {joins(:periodo).where('periodos.id = ?', periodo_id)}
	scope :de_la_escuela, -> (escuela_id) {joins(:escuela).where('escuelas.id = ?', escuela_id)}
	scope :de_la_escuela_y_periodo, -> (escuelaperiodo_id) {where('escuelaperiodo_id = ?', escuelaperiodo_id)}
	scope :del_estudiante, -> (estudiante_id) {where('usuario_id = ?', estudiante_id)}
	scope :preinscritos, -> {where(tipo_estado_inscripcion_id: TipoEstadoInscripcion::PREINSCRITO)}
	scope :inscritos, -> {where(tipo_estado_inscripcion_id: TipoEstadoInscripcion::INSCRITO)}
	scope :reservados, -> {where(tipo_estado_inscripcion_id: TipoEstadoInscripcion::RESERVADO)}
	# scope :con_reportepago, -> {joins(:reportepago)}
	scope :con_reportepago, -> {where('reportepago_id IS NOT NULL')}
	scope :sin_reportepago, -> {where(reportepago_id: nil)}

	scope :total_inscripciones, -> {inscripcionsecciones.count}
	scope :total_inscripciones_calificadas, -> {joins(:inscripcionsecciones).where('inscripcionsecciones.estado = 1 or inscripcionsecciones.estado = 2')}

	# FUNCIONES: 
	def revisar_reglamento
		reglamento_aux = :regular
		if inscribio_pero_no_aprobo_ninguna?
			reglamento_aux = :articulo_3
			iep_anterior = self.anterior_iep
			if iep_anterior and iep_anterior.inscribio_pero_no_aprobo_ninguna?
				reglamento_aux = :articulo_6
				iep_anterior2 = iep_anterior.anterior_iep
				if iep_anterior2 and iep_anterior2.inscribio_pero_no_aprobo_ninguna?
					reglamento_aux = :articulo_7
				end
			end
		end
		return reglamento_aux
	end

	def inscribio_pero_no_aprobo_ninguna?
		self.inscripcionsecciones.any? and !(self.inscripcionsecciones.aprobado.any?)
	end

	def anterior_iep
		escu_per_ant = self.escuelaperiodo.escuelaperiodo_anterior
		Inscripcionescuelaperiodo.where(grado_id: self.grado_id, escuelaperiodo_id: escu_per_ant.id).first
	end

	def find_enroll_academic_process
		escuelaperiodo = Escuelaperiodo.where(escuela_id: grado.escuela_id, periodo_id: periodo&.id).first
		ap = escuelaperiodo.find_or_create_academic_process
		grade = grado.find_or_create_grade		
		EnrollAcademicProcess.where(grade_id: grade.id, academic_process_id: ap.id).first
	end

	def find_or_create_enroll_academic_process
		escuelaperiodo = Escuelaperiodo.where(escuela_id: grado.escuela_id, periodo_id: periodo&.id).first
		ap = escuelaperiodo.find_or_create_academic_process
		grade = grado.find_or_create_grade
		

		eap = EnrollAcademicProcess.where(grade_id: grade.id, academic_process_id: ap.id).first
		if eap.nil?
		  if tipo_estado_inscripcion_id.eql? 'NUEVO'
			permanence_status = :nuevo 
		  elsif tipo_estado_inscripcion_id.eql? 'REINC'
			permanence_status = :reincorporado
		  else
			permanence_status = :regular
		  end
		  eap = EnrollAcademicProcess.create(grade_id: grade.id, academic_process_id: ap.id, permanence_status: permanence_status, enroll_status: :confirmado)
		end
		return eap
	end	

	def migrate_reportepago
		
			enroll = find_or_create_enroll_academic_process

			have_report = enroll.payment_reports.any?
			if enroll and !have_report
				adjunto = Adjunto.where(name: 'respaldo', record_type: 'Reportepago', record_id: self.id).first

				payment_preport = PaymentReport.new
				payment_preport.payable_type = 'EnrollAcademicProcess'
				payment_preport.payable_id =  enroll.id
				payment_preport.amount = reportepago.monto
			
				payment_preport.status = (tipo_estado_inscripcion_id.eql? 'INS') ? :Validado : :Pendiente
				payment_preport.transaction_id = reportepago.numero

				payment_preport.receiving_bank_account_id = BankAccount.first.id
				payment_preport.transaction_date = reportepago.fecha_transaccion
				payment_preport.transaction_type = reportepago.tipo_transaccion
				
				# Buscar Banco
				bank = Bank.find_by(code: reportepago.banco_origen_id)
				payment_preport.origin_bank_id = bank.id
				
				# Adjunto
				if adjunto
					blob_id = adjunto.adjuntoblob_id
					blob = ActiveStorage::Blob.find blob_id
					payment_preport.voucher.attach blob if blob
				end
				return payment_preport.save ? '+' : "X: #{payment_preport.errors.full_messages.to_sentence}"
			else
				return enroll.nil? ? "*" : '='
			end

	end

	def label_estado_inscripcion
		# ["CO", "INS", "NUEVO", "PRE", "REINC", "RES", "RET", "VAL"] 

		if self.tipo_estado_inscripcion
			case self.tipo_estado_inscripcion_id
			when TipoEstadoInscripcion::INSCRITO
				label_color = 'success'
			when TipoEstadoInscripcion::PREINSCRITO
				label_color = 'info'
			when TipoEstadoInscripcion::RETIRADA
				label_color = 'danger'
			else
				label_color = 'secondary'
			end
			return " <span class='badge badge-#{label_color} text-center'>#{self.tipo_estado_inscripcion.descripcion.titleize}</span>".html_safe
		else
			return ''
		end
	end

	def limite_creditos_permitidos
		self.escuelaperiodo.limite_creditos_permitidos
	end


	def total_asignaturas
		asignaturas.count
	end

	def total_creditos
		asignaturas.sum(:creditos)
	end

	def decripcion_amplia
		"#{escuela.descripcion} #{periodo.id} #{estudiante.descripcion}"
	end

	def descripcion
		"#{escuela.id}-#{periodo.id}-#{estudiante.id}"
	end

	def inscrito?
		self.tipo_estado_inscripcion.inscrito?
	end

	def preinscrito?
		tipo_estado_inscripcion.preinscrito?
	end

	def reservado?
		tipo_estado_inscripcion.reservado?
	end


	def self.find_or_new(grado_id, periodo_id)

		grado = Grado.find grado_id
		escuela_id = grado.escuela_id
		estudiante_id = grado.estudiante_id
		escupe = Escuelaperiodo.where(periodo_id: periodo_id, escuela_id: escuela_id).first
		# ins_periodo = estudiante.inscripcionescuelaperiodos.de_la_escuela_y_periodo(escupe.id).first

		ins_escuelaperiodo = Inscripcionescuelaperiodo.where(grado_id: grado_id, escuelaperiodo_id: escupe.id).first

		if ins_escuelaperiodo.nil?
			ins_escuelaperiodo = Inscripcionescuelaperiodo.new
			ins_escuelaperiodo.estudiante_id = estudiante_id
			ins_escuelaperiodo.escuelaperiodo_id = escupe.id
			ins_escuelaperiodo.grado_id = grado_id
		end

		return ins_escuelaperiodo

	end

	def confirmar_con_correo
		if self.update(tipo_estado_inscripcion_id: TipoEstadoInscripcion::INSCRITO)
			if EstudianteMailer.confirmado(estudiante, self).deliver_later
				Bitacora.create!(
				descripcion: "Se envió correo de confirmacion de inscripción estudiante #{self.estudiante_id} en periodo #{self.periodo.id} en #{self.escuela.descripcion}.", 
				tipo: Bitacora::CREACION,
				usuario_id: nil,
				comentario: nil,
				id_objeto: self.id,
				tipo_objeto: self.class.name,
				ip_origen: 'localhost'
				)

			end
		end		
	end

	def bitacora_confirmacion_inscripcion
		if self.tipo_estado_inscripcion_id.eql? TipoEstadoInscripcion::INSCRITO

			Bitacora.create!(
			descripcion: "Confirmada inscripción del estudiante #{self.estudiante_id} en periodo #{self.periodo.id} en #{self.escuela.descripcion}.", 
			tipo: Bitacora::CREACION,
			usuario_id: nil,
			comentario: nil,
			id_objeto: self.id,
			tipo_objeto: self.class.name,
			ip_origen: 'localhost'
			)

		end
		
	end
end
