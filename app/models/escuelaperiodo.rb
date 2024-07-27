# == Schema Information
#
# Table name: escuelaperiodos
#
#  id              :bigint           not null, primary key
#  max_asignaturas :integer
#  max_creditos    :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  escuela_id      :string(255)
#  periodo_id      :string(255)
#
# Indexes
#
#  index_escuelaperiodos_on_escuela_id                 (escuela_id)
#  index_escuelaperiodos_on_escuela_id_and_periodo_id  (escuela_id,periodo_id) UNIQUE
#  index_escuelaperiodos_on_periodo_id                 (periodo_id)
#  index_escuelaperiodos_on_periodo_id_and_escuela_id  (periodo_id,escuela_id) UNIQUE
#
# Foreign Keys
#
#  escuelaperiodos_escuela_id_fkey  (escuela_id => escuelas.id)
#
class Escuelaperiodo < ApplicationRecord

	# ASOCIACIONES: 
	belongs_to :periodo
	belongs_to :escuela

	has_many :jornadacitahorarias, dependent: :destroy

	has_many :inscripcionescuelaperiodos
	accepts_nested_attributes_for :inscripcionescuelaperiodos
	# VALIDACIONES:
	# validates :id, presence: true, uniqueness: true
	validates_uniqueness_of :periodo_id, scope: [:escuela_id], message: 'La escuela ya está en este período', field_name: false

	
	# def grados_sin_cita_horaria

	# end

	# def grados_sin_cita_horaria_ordenados
	# 	self.escuela.grados.no_preinscrito.sin_cita_horarias.order([eficiencia: :desc, promedio_simple: :desc, promedio_ponderado: :desc])
	# end

	def find_academic_process
		academic_process_start_name = "#{self.escuela.id} | #{self.periodo_id}"
		AcademicProcess.where(name: academic_process_start_name).first	
	end

	def find_or_inicialize_academic_process
		
		school_id = escuela.find_school&.id 
		letter = periodo_id.last
		modality = AcademicProcess.letter_to_modality letter
		p_id = periodo_id.delete(periodo_id.last)
		year, type = p_id.split('-')
		tipo_periodo = PeriodType.find_by(code: type)
		period = Period.find_or_create_by(year: year, period_type_id: tipo_periodo) 
		
		AcademicProcess.find_or_initialize_by(school_id: school_id, period_id: periodo.id, modality: modality)	
		
	end
	def find_or_create_academic_process
		
		school_id = escuela.find_school&.id 

		# p "∫chool_id: #{school_id}"
		letter = periodo_id.last
		# p "Letter: #{letter}"
		modality = AcademicProcess.letter_to_modality letter.upcase
		# p "Modality: #{modality}"

		p_id = periodo_id.delete(periodo_id.last)
		year, type = p_id.split('-')
		period_type = PeriodType.find_by(code: type)
		# p "period_type: #{period_type.code}"

		period = Period.find_or_create_by(year: year, period_type_id: period_type.id) 
		if period.nil?
			p "Period no encontrado: year: #{year} type: #{type} modality: #{modality} period_type: #{period_type}"
		end

		ap = AcademicProcess.find_by(school_id: school_id, period_id: period.id, modality: modality.to_sym)	
		if ap.nil?
			p "AcademicProcess no encontrado. se procede a crearlo: year= #{year} type= #{type} modality= #{modality} period_type_id= #{period_type.id}"
			ap = AcademicProcess.create(school_id: school_id, period_id: period.id, modality: modality.to_sym, max_credits: 48, max_subjects: 5)
		end
		return ap
	end	

	def semestral?
		periodo.semestral?
	end

	def anual?
		periodo.anual?
	end

	def periodos_ultimo_año_ids
		periodos_ids = []
		if escupe_anterior = escuelaperiodo_anterior
			periodos_ids << escupe_anterior.periodo_id
			escuepe_anteanterior = escupe_anterior.escuelaperiodo_anterior
			if semestral? and escuepe_anteanterior
				periodos_ids << escuepe_anteanterior.periodo_id
			end
		end
		periodos_ids.reverse
	end

	def periodos_ultimo_año
		Periodo.where(periodo_id: periodos_ultimo_año_ids)
	end


	def escuelaperiodo_anterior
		periodo_anterior = escuela.periodo_anterior periodo_id
		Escuelaperiodo.where(periodo_id: periodo_anterior.id, escuela_id: escuela_id).first
	end

	def total_secciones
		secciones.count
	end

	def secciones
		Seccion.de_la_escuela(self.escuela_id).del_periodo(self.periodo_id)
	end

	def descripcion_id
		"#{escuela_id}-#{periodo_id}"
	end

	def limite_creditos_permitidos
		self.max_creditos
	end
	
	def limite_asignaturas_permitidas
		self.max_asignaturas
	end

end
