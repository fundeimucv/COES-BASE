# == Schema Information
#
# Table name: inscripcionsecciones
#
#  id                           :bigint           not null, primary key
#  calificacion_final           :float
#  calificacion_posterior       :float
#  estado                       :integer          not null
#  pci                          :integer
#  primera_calificacion         :float
#  segunda_calificacion         :float
#  tercera_calificacion         :float
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  escuela_id                   :string(255)
#  estudiante_id                :string(255)
#  grado_id                     :bigint
#  inscripcionescuelaperiodo_id :bigint
#  pci_escuela_id               :string(255)
#  seccion_id                   :bigint
#  tipo_calificacion_id         :string(255)
#  tipo_estado_calificacion_id  :string(255)
#  tipo_estado_inscripcion_id   :string(255)
#  tipoasignatura_id            :string(255)
#
# Indexes
#
#  fk_rails_24a264013f                                         (pci_escuela_id)
#  fk_rails_d28b12f260                                         (grado_id)
#  fk_rails_d92b783c84                                         (tipo_calificacion_id)
#  index_inscripcionsecciones_on_escuela_id                    (escuela_id)
#  index_inscripcionsecciones_on_estudiante_id                 (estudiante_id)
#  index_inscripcionsecciones_on_estudiante_id_and_seccion_id  (estudiante_id,seccion_id) UNIQUE
#  index_inscripcionsecciones_on_inscripcionescuelaperiodo_id  (inscripcionescuelaperiodo_id)
#  index_inscripcionsecciones_on_seccion_id                    (seccion_id)
#  index_inscripcionsecciones_on_seccion_id_and_estudiante_id  (seccion_id,estudiante_id) UNIQUE
#  index_inscripcionsecciones_on_tipo_estado_calificacion_id   (tipo_estado_calificacion_id)
#  index_inscripcionsecciones_on_tipo_estado_inscripcion_id    (tipo_estado_inscripcion_id)
#  index_inscripcionsecciones_on_tipoasignatura_id             (tipoasignatura_id)
#
class Inscripcionseccion < ApplicationRecord
  self.table_name = 'inscripcionsecciones'
  # SET GLOBALES:
  FINAL = TipoCalificacion::FINAL
  PARCIAL = TipoCalificacion::PARCIAL
  DIFERIDO = TipoCalificacion::DIFERIDO
  REPARACION = TipoCalificacion::REPARACION
  PI = TipoCalificacion::PI

  # ASOCIACIONES: 
  belongs_to :seccion, class_name: 'Seccion'
  belongs_to :inscripcionescuelaperiodo

  has_one :asignatura, through: :seccion#, class_name: 'Seccion', foreign_key: :id
  # has_one :periodo, through: :seccion, class_name: 'Seccion'

  belongs_to :grado
  belongs_to :estudiante
  belongs_to :escuela

  belongs_to :pci_escuela, foreign_key: 'pci_escuela_id', class_name: 'Escuela', optional: true

  # has_many :programaciones, through: :asignatura, source: :periodo

  has_one :usuario, through: :estudiante
  belongs_to :tipo_calificacion
  belongs_to :tipoasignatura, optional: true
  
  # VARIABLES:
  enum estado: [:sin_calificar, :aprobado, :aplazado, :retirado, :trimestre1, :trimestre2]

  # TRIGGERS:
  after_initialize :set_default, :if => :new_record?
  before_validation :set_estados
  after_save :actualizar_estados
  after_save :calcular_numeros_del_grado, if: :will_save_change_to_calificacion_final?
  after_save :calcular_numeros_del_grado, if: :will_save_change_to_calificacion_posterior?

  before_destroy :set_bitacora
  after_destroy :destroy_inscripcionescuelaperiodo


  # VALIDACIONES:
  validates_presence_of :grado_id
  validates_presence_of :estudiante_id
  validates_presence_of :seccion_id

  validates_uniqueness_of :grado_id, scope: [:seccion_id], message: 'El estudiante ya está inscrito en la sección', field_name: false

  validates_with AsignaturaPeriodoInscripcionUnicaValidator, field_name: false, if: :new_record?
  # validates_with AsignaturaAprobadaUnicaValidator, field_name: false, if: :new_record?

  # SCOPES:
  scope :preinscritos, -> {joins(:inscripcionescuelaperiodo).where('inscripcionescuelaperiodos.tipo_estado_inscripcion_id = ?', TipoEstadoInscripcion::PREINSCRITO)}
  scope :inscritos, -> {joins(:inscripcionescuelaperiodo).where('inscripcionescuelaperiodos.tipo_estado_inscripcion_id = ?', TipoEstadoInscripcion::INSCRITO)}


  # scope :con_totales, ->(escuela_id, periodo_id) {joins(:escuela).where("escuelas.id = ?", escuela_id).del_periodo(periodo_id).joins(:usuario).order("usuarios.apellidos ASC").joins(:asignatura).group(:estudiante_id).select('estudiante_id, usuarios.apellidos apellidos, usuarios.nombres nombres, SUM(asignaturas.creditos) total_creditos, COUNT(*) asignaturas, SUM(IF (inscripcionsecciones.estado = 1, asignaturas.creditos, 0)) aprobados')}


  scope :con_totales, ->(escuela_id, periodo_id) {joins(:escuela).where("escuelas.id = ?", escuela_id).del_periodo(periodo_id).joins(:usuario).joins(:asignatura).joins(grado: :plan).group(:grado_id).select('planes.id plan_id, planes.creditos plan_creditos, grados.*, SUM(asignaturas.creditos) total_creditos, COUNT(*) asignaturas, SUM(IF (inscripcionsecciones.estado = 1, asignaturas.creditos, 0)) aprobados')}

  scope :por_confirmar, -> {where(inscripcionescuelaperiodo_id: nil)}

  # scope :ratificados, -> {inscritos}
  # scope :no_ratificados, -> {where("inscripcionsecciones.tipo_estado_inscripcion_id <> 'RAT'")}
  # scope :no_ratificados, -> {where("inscripcionsecciones.tipo_estado_inscripcion_id IS NULL OR inscripcionsecciones.tipo_estado_inscripcion_id <> '#{TipoEstadoInscripcion::RATIFICADO}'")}

  # scope :confirmados, -> {where "confirmar_inscripcion = ?", 1}
  # scope :del_periodo_actual, -> {joins(:seccion).where "periodo_id = ?", ParametroGeneral.periodo_actual_id}
  # SON EQUIVALENTES LAS 2 SIGUIENTES SCOPE PERO FUNCIONAN DIFERENTES EN CONDICIONES PARTICULARES: 
  # scope :del_periodo, lambda { |periodo_id| includes(:seccion).where "secciones.periodo_id = ?", periodo_id}
  scope :del_periodo, lambda { |periodo_id| joins(:seccion).where "secciones.periodo_id = ?", periodo_id}
  scope :de_los_periodos, lambda { |periodos_ids| joins(:seccion).where "secciones.periodo_id IN (?)", periodos_ids}


  # scope :en_reparacion, -> {joins(:seccion).where "secciones.tipo_seccion_id = ?", TipoSeccion::REPARACION}
  scope :en_reparacion, -> {where tipo_calificacion_id.eql? REPARACION}
  # scope :no_retirados, -> {where "tipo_estado_inscripcion_id != ?", RETIRADA}

  scope :de_la_escuela, lambda {|escuela_id| includes(:escuela).where("escuelas.id = ?", escuela_id).references(:escuelas)}

  scope :del_estudiante, lambda {|estudiante_id| where("estudiante_id = ?", estudiante_id)}
  # Así debe ser de_la_escuela
  # scope :de_la_escuela, lambda {|escuela_id| where("escuelas_id = ?", escuela_id)}
  # scope :de_las_escuelas, lambda {|escuelas_ids| where("escuelas.id IN (?)", escuelas_ids)}

  scope :de_las_escuelas, lambda {|escuelas_ids| includes(:escuela).where("escuelas.id IN (?)", escuelas_ids).references(:escuelas)}

  scope :proyectos, -> {joins(:asignatura).where("asignaturas.tipoasignatura_id = ?", Tipoasignatura::PROYECTO)}

  scope :posibles_graduandos, -> {joins(:grado).where("grados.estado = 2")}

  scope :no_absolutas, -> {joins(:asignatura).where("asignaturas.calificacion != 1")}
  scope :absolutas, -> {joins(:asignatura).where("asignaturas.calificacion = 1")}

  scope :no_retirados, -> {where "inscripcionsecciones.estado != 3"}
  scope :cursadas, -> {where "inscripcionsecciones.estado = 1 or inscripcionsecciones.estado = 2"}
  scope :en_curso, -> {where "inscripcionsecciones.estado != 1 and inscripcionsecciones.estado != 2 and inscripcionsecciones.estado != 3"} # Excluye retiradas también
  scope :aprobadas, -> {where "inscripcionsecciones.estado = 1"}
  
  scope :total_creditos_cursados_en_periodos, lambda{|periodos_ids| cursadas.joins(:seccion).where('secciones.periodo_id IN (?)', periodos_ids).joins(:asignatura).sum('asignaturas.creditos')}

  scope :total_creditos_aprobados_en_periodos, lambda{|periodos_ids| aprobadas.joins(:seccion).where('secciones.periodo_id IN (?)', periodos_ids).joins(:asignatura).sum('asignaturas.creditos')}

  scope :total_creditos, -> {joins(:asignatura).sum('asignaturas.creditos')}

  scope :total_creditos_cursados, -> {cursadas.total_creditos}
  scope :total_creditos_aprobados, -> {aprobadas.total_creditos}
  
  # scope :ponderado, -> {joins(:asignatura).cursadas.sum('asignaturas.creditos * calificacion_final')}
  scope :ponderado, -> {ponderado_finales+ponderado_posteriores}
  
  scope :ponderado_finales, -> {joins(:asignatura).cursadas.where(calificacion_posterior: nil).sum('asignaturas.creditos * calificacion_final')}
  scope :ponderado_posteriores, -> {joins(:asignatura).cursadas.where('calificacion_posterior IS NOT NULL').sum('asignaturas.creditos * calificacion_posterior')}

  # scope :peso_asignaturas, -> {joins(:asignatura).cursadas.sum('asignaturas.creditos * calificacion_final')}
  # scope :ponderado, -> {peso_asignaturas/total_creditos_cursados}

  scope :promedio, -> {cursadas.average('calificacion_final')}
  scope :promedio_aprobadas, -> {aprobadas.promedio}
  scope :ponderado_aprobadas, -> {aprobadas.ponderado}

  scope :sin_equivalencias, -> {joins(:seccion).where "secciones.tipo_seccion_id != 'EI' and secciones.tipo_seccion_id != 'EE'"} 
  scope :por_equivalencia, -> {joins(:seccion).where "secciones.tipo_seccion_id = 'EI' or secciones.tipo_seccion_id = 'EE'"}
  scope :por_equivalencia_interna, -> {joins(:seccion).where "secciones.tipo_seccion_id = 'EI'"}
  scope :por_equivalencia_externa, -> {joins(:seccion).where "secciones.tipo_seccion_id = 'EE'"}

  scope :estudiantes_inscritos_del_periodo, lambda { |periodo_id| joins(:seccion).where("secciones.periodo_id": periodo_id).group(:estudiante_id).count } 

  scope :por_total_calificaciones?, -> {joins(:asignatura).group("asignaturas.calificacion").count}

  scope :estudiantes_inscritos, -> { group(:estudiante_id).count } 

  scope :estudiantes_inscritos_con_creditos, -> { joins(:asignatura).group(:estudiante_id).sum('asignaturas.creditos')} 

  # Esta función retorna la misma cuenta agrupadas por creditos de asignaturas
  scope :estudiantes_inscritos_con_creditos2, -> { joins(:asignatura).group('inscripcionsecciones.estudiante_id', 'asignaturas.creditos').count} 

  scope :secciones_creadas, -> { group(:seccion_id).count }

  scope :con_calificacion, -> {where('inscripcionsecciones.estado >= 1 and inscripcionsecciones.estado <= 3')}


# Inscripcionseccion.joins(:seccion).joins(:estudiante).where("estudiantes.escuela_id": 'IDIO', "secciones.periodo_id": '2018-02A').group(:estudiante_id).count.count


  # Probar pero no hace falta ya que podemos hacer Inscripcionseccion.retirado / aprobado / aplazado / sin_calificacion
  # scope :retirados, -> {where "estado = 3"}
  # scope :aprobados, -> {where "estado = 1", :aprobado}
  # scope :aplazados, -> {where "estado = 2", :aplazado}
  # scope :sin_calificar, -> {where "tipo_calificacion_id = ?", 'SC'}

  scope :perdidos, -> {where "tipo_calificacion_id = ?", PI}

  scope :como_pcis, -> {where pci: true}

  # scop :not_secciones_r, -> {joins(:seccion).where.not("secciones.numero ILIKE '%(R)%'")}

  # scope :pcis_pendientes_por_asociar, -> {joins(:escuela).where("pci_escuela_id IS NULL and (escuela.id ON ( SELECT escuelas.id FROM escuelas INNER JOIN grados ON escuelas.id = grados.escuela_id WHERE grados.estudiante_id = ? ) )", self.estudiante_id)}

  # Funciones de Estilo

  def calificacion_definitiva
    calificacion_posterior.nil? ? calificacion_final : calificacion_posterior
  end
  def tr_class_style_qualify
    valor = ''
    valor = 'table-success' if self.aprobado?
    valor = 'table-danger' if (self.aplazado? || self.retirado? || self.pi?)
    valor += ' text-muted' if self.retirado?
    return valor
  end

  def descripcion_ultimo_plan
    plan = ultimo_plan
    if plan
      plan.descripcion_filtro
    else
      'Sin Plan Asignado'
    end
  end

  def general_desc
    "#{seccion.descripcion_simple} : #{estudiante_id}"
  end
  def pi?
    tipo_estado_calificacion_id.eql? 'PI'
  end

  def rt?
    retirado?
  end

  def pi_or_rt?
    (pi? or rt?)
  end
  def get_status 
    if tipo_calificacion_id.eql? 'PI'
      return :perdida_por_inasistencia
    elsif (self.trimestre1? or trimestre2?)
      return :sin_calificar
    else
      return estado
    end
  end

  def get_type_q
    if tipo_estado_calificacion_id.eql? 'ND'
      :diferido
    elsif tipo_estado_calificacion_id.eql? 'NR'
      :reparacion
    else
      :final
    end
  end
  
  def get_type_q_post
    (tipo_estado_calificacion_id.eql? 'ND') ? :diferido : :reparacion
  end

  def descrip_to_file
    "#{estudiante_id}, #{calificacion_final}, #{seccion.periodo_id}, #{seccion.asignatura_id}, #{seccion.numero}"
  end
  # Funciones de importación:

  def self.total_import offset


    p 'iniciando migración de registros académicos... '
    total_exist = 0
    total_new_records = 0
    total_errors = 0
    with_errors = []
  
    total_mgs = ""
  
    # Inscripcionseccion.joins(:seccion).where.not("secciones.numero = 'R' or secciones.numero ILIKE '%(R)%'").order(:created_at).each_with_index do |ar, i|
    Inscripcionseccion.all.offset(offset).order(created_at: :desc).each_with_index do |ar, i|
      begin
        
        salida = ar.import_academic_record
  
        print salida
        if salida.eql? '+'
          total_new_records += 1
        elsif salida.eql? '='
          total_exist += 1
        else
          p ar.general_desc
          total_errors += 1
          with_errors << ar.id
        end

        # if i.eql? 10000
        #   msg = "            Resumen hasta el registro #{i}:         ".center(400, '-')
        #   msg += "      Total Existentes: #{total_exist}      ".center(400, '-')
        #   msg += "      Total Nuevos Registros: #{total_new_records}      ".center(400, '-')
        #   msg += "      Total Errores: #{total_errors}      ".center(400, '-')
        #   msg += "      Detalles IDs Errores: #{with_errors}      ".center(400, '-')
        #   UserMailer.general(User.first, msg).deliver_now
        # end
        
      rescue StandardError => e
        msg = "#{e} | (#{ar.id}) #{ar.general_desc}"
        UserMailer.general(User.first, msg).deliver_now
        break
      end
    end
      
    total_mgs += "      Total Esperado: #{Inscripcionseccion.count}       ".center(400, '-')
    total_mgs += "      Total Nuevos registros agregados: #{total_new_records}       ".center(400, '-')
    total_mgs += "      Total Existentes: #{total_exist}       ".center(400, '-')
    total_mgs += "      Total Errores: #{total_errors}       ".center(400, '-')
    total_mgs += "      Identificadores de Inscripcionseccion con errores: #{with_errors}    "
  
    begin
      UserMailer.general(User.first, total_mgs).deliver
    rescue Exception => e
      p 'Error enviando correo'
    end
    p with_errors

    
    
  end






  def import_academic_record
    # AcademicRecord:
      # status: {sin_calificar: 0, aprobado: 1, aplazado: 2, retirado: 3, perdida_por_inasistencia: 4}
      # permanence_status: [:nuevo, :regular, :reincorporado, :articulo3, :articulo6, :articulo7, :intercambio, :desertor, :egresado, :egresado_doble_titulo, :permiso_para_no_cursar]  
  
    # Partial Qualification
      # partial: {primera: 1, segunda: 2, tercera: 3}
      # value
    # Inscripcionseccion:
      # estado:    
        # estado: [:sin_calificar, :aprobado, :aplazado, :retirado, :trimestre1, :trimestre2]
      # Tipo Calificacion:
        # ND: :Diferido, NF: Final, NR: Reparación, PI: Pérdida Por Inasistencia, PR: Parcial
      # TipoEstadoIscripcion:
        # CO: Congelado, INS: Inscrito, NUEVO: Nuevo Ingreso, PRE: Preinscrito, REINC: Reincorporado, RES: Reservado, RET: Retirado, VAL: Válido para inscribir
      # calificacion_final
      # calificacion_posterior
      # primera_calificacion
      # segunda_calificacion
      # tercera_calificacion   
    begin      
      escuelaperiodo = Escuelaperiodo.where(escuela_id: escuela_id, periodo_id: periodo&.id).first
      ap = escuelaperiodo.find_or_create_academic_process

      grade = grado.find_grade
      # p "   Grado: #{grade.id}      ".center(500, 'G')
      
      eap = EnrollAcademicProcess.find_by(grade_id: grade.id, academic_process_id: ap.id)
      if eap.nil?
        
        if tipo_estado_inscripcion_id.eql? 'NUEVO'
          permanence_status = :nuevo 
        elsif tipo_estado_inscripcion_id.eql? 'REINC'
          permanence_status = :reincorporado
        else
          permanence_status = :regular
        end
        eap = EnrollAcademicProcess.new(grade_id: grade.id, academic_process_id: ap.id, permanence_status: permanence_status, enroll_status: :confirmado)
        if eap.save
          print "*NEAP#{eap.id}*"
        else
          p "   EnrollAcademicProcess Error: #{eap.errors.full_messages.to_sentence}      ".center(500, 'E')
        end
      end

      if seccion.es_de_reparacion?
        hermana = seccion.seccion_hermana
        section = hermana&.find_or_create_section
        es_reparacion = true
      else
        es_reparacion = false
        section = seccion.find_or_create_section
      end

      # Se encuentra o crea el Registro Academico:
      academic_record = AcademicRecord.find_by(enroll_academic_process_id: eap.id, section_id: section.id)
      
      if academic_record.nil?
        academic_record = AcademicRecord.new(enroll_academic_process_id: eap.id, section_id: section.id, status: get_status)
        if academic_record.save(validate: false)
          print "*NAR #{academic_record.id}*" 
          estado_import = '+'
        else
          estado_import = academic_record.errors.full_messages.to_sentence
          return estado_import
        end
      else
        estado_import = '='
      end

      # Se registran Calificaciones Parciales de ser el caso:
      if es_reparacion
        academic_record.qualifications.create(type_q: :reparacion, value: calificacion_final.to_i) if !academic_record.qualifications.reparacion.any?
      else
        academic_record.partial_qualifications.create(partial: :primera, value: primera_calificacion.to_i) if (primera_calificacion and !academic_record.partial_qualifications.primera.any?)
        academic_record.partial_qualifications.create(partial: :segunda, value: segunda_calificacion.to_i) if (segunda_calificacion and !academic_record.partial_qualifications.segunda.any?)
        academic_record.partial_qualifications.create(partial: :tercera, value: tercera_calificacion.to_i) if (tercera_calificacion and !academic_record.partial_qualifications.tercera.any?)
        
        # Se registra Calificación Final de ser el caso:
        academic_record.qualifications.create(type_q: :final, value: calificacion_final.to_i) if calificacion_final and !academic_record.qualifications.final.any?
  
        # Se registran Calificaciones Posteriores de ser el caso:
        academic_record.qualifications.create(type_q: get_type_q_post, value: calificacion_posterior.to_i) if calificacion_posterior and !academic_record.qualifications.post.any?
      end      

      return estado_import
    rescue Exception => e
      "                    Error: #{e} |  Estudiante: #{estudiante_id} |  Sección: #{seccion_id}                   ".center(500, '#')
    end
    
  end
  # Funciones Generales

  def periodo
    seccion&.periodo
  end

  def datos_para_excel

    data = [self.estudiante_id, self.nombre_estudiante_con_retiro]

    if self.inscripcionescuelaperiodo 
      data << self.inscripcionescuelaperiodo.tipo_estado_inscripcion.descripcion

      if self.inscripcionescuelaperiodo.tipo_estado_inscripcion_id.eql? TipoEstadoInscripcion::INSCRITO
        data += [self.usuario.email, self.usuario.telefono_movil]
      else
        data += ['--', '--']
      end

    else
      data += ['--', '--', '--']
    end
    return data
  end


  def ultimo_plan
    grado ? grado.ultimo_plan : nil
  end

  # Este método no debe ir ya que es una relación belong_to definida arriba
  # def grado
  #   # escuela_id = self.pci_escuela_id ? self.pci_escuela_id : self.escuela.id
  #   Grado.where(estudiante_id: self.estudiante_id, escuela_id: escuela_id).first
  # end

  def descripcion_asignatura_pdf
    aux = asignatura.descripcion
    aux += " <b> (PCI) </b>" if self.como_pci?
    aux += " <b> (#{retirado_en_letras}) </b>" if self.retirado?
    return aux
  end

  def retirado_en_letras
    gen = estudiante.usuario.genero
    if retirado?
      return "Retirad#{gen}"
    else
      return ""
    end
  end

  def id_foranea
    foranea? ? "foranea_#{id}" : id
  end

  def foranea?
    !(estudiante.escuelas.include? asignatura.escuela)
  end

  def pci_pendiente_por_asociar? 
    pci_escuela_id.nil? and foranea?
  end

  def como_pci?
    !pci_escuela_id.nil?
  end

  def label_pci
    if como_pci?
      return "<span class='badge badge-success'>PCI para #{pci_escuela.descripcion}</span>" 
    else
      return ""
    end
  end

  def estado_a_letras
    case estado
    when 'retirado'
      return 'RT'
    when 'aprobado'
      return 'A'
    when 'aplazado'
      return 'AP'
    else
      return 'SC'
    end
  end

  def estado_inscripcion
    if self.sin_calificar?
      if inscripcionescuelaperiodo and inscripcionescuelaperiodo.tipo_estado_inscripcion
        return inscripcionescuelaperiodo.tipo_estado_inscripcion.descripcion.titleize
      else
        return ''
      end
    else
      return self.estado.titleize
    end
  end

  def estado_segun_calificacion
    
    if seccion and asignatura and !asignatura.absoluta?
      nota = (reparacion? || diferido?) ? calificacion_posterior : calificacion_final
      if nota and nota >= 10 
        return :aprobado
      else
        return :aplazado
      end
    else
      return self.estado
    end

  end

  def pi?
    tipo_calificacion_id.eql? PI
  end

  def reparacion?
    self.tipo_calificacion_id.eql? REPARACION
  end

  def diferido?
    self.tipo_calificacion_id.eql? DIFERIDO
  end

  def no_presento?
    self.diferido?
  end

  def d_or_r?
    tipo_calificacion_id.to_s.first
  end

  def nota_final_para_csv reparacion = false
    # Notas 00 a 20 / AP = Aplasado, A = Aprobado, PI = , SN = Sin nota, NP
    if self.pi?
      return'00'
    elsif self.retirado?
      return 'RT'
    elsif self.sin_calificar?
      return 'SN'
    elsif self.asignatura.absoluta? or self.asignatura.forzar_absoluta
      if self.aprobado?
        return 'A'
      else
        return 'AP'
      end
    else
      return self.colocar_nota_final.to_s
    end
  end


  def tipo_convocatoria explicita = nil

    if explicita.eql? 'F'
      return "F#{seccion.periodo.valor_para_tipo_convocatoria}"
    elsif explicita.eql? 'R'
      return "R#{seccion.periodo.valor_para_tipo_convocatoria}"
    else
      if self.reparacion?
        return "R#{seccion.periodo.valor_para_tipo_convocatoria}"
      else
        return "F#{seccion.periodo.valor_para_tipo_convocatoria}"
      end
    end
  end

  # def calificacion_para_kardex
  #   return calificacion_completa? ? calificacion_final : 'SN'
  # end

  # def reprobada?
  #   return aplazada?
  # end
  # def aplazada?
  #   if asignatura.absoluta?
  #     return (tipo_estado_calificacion_id.eql? 'AP' or no_presento?)
  #   elsif no_presento? and calificacion_final < 10
  #     return true
  #   else 
  #     return tipo_estado_calificacion_id.eql? 'AP'
  #   end
  # end

  # ATENCIÓN: ESTA FUNCIÓN SE USA PARA CASOS EN LOS QUE EL REGISTRO ESTÉ AÚN EN MEMORIA, POR LO QUE NO SE HAYA ASIGNADO EL VALOR DEL ESTADO EN set_estados
  def aprobada?
    if asignatura.absoluta?
      if no_presento?
        return false
      else
        tipo_estado_calificacion_id.eql? 'A'
      end 
    elsif no_presento?
      return calificacion_final > 10
    else
      return tipo_estado_calificacion_id.eql? 'A'
    end

  end

  # def calificacion_completa?
  #   if primera_calificacion.nil? or segunda_calificacion.nil? or tercera_calificacion.nil? or calificacion_final.nil?
  #     return false
  #   else
  #     return true
  #   end
  # end

  def descripcion periodo_id
    aux = asignatura.descripcion_pci periodo_id
    aux += " <b>(Retirada)</b>" if retirado?
    return aux
  end

  # def estado
  #   if retirado?
  #     return "Retirada"
  #   elsif aprobada?
  #     return 'Aprobada'
  #   elsif aplazada?
  #     return 'Aplazada'
  #   else
  #     return tipo_estado_calificacion.descripcion.titleize
  #   end

  # end

  def valor_calificacion incluir_tipo = false, final_o_posterior = nil
    valor = ''
    if retirado?
      valor = '--'
    elsif asignatura.absoluta? or self.asignatura.forzar_absoluta
      if self.sin_calificar?
        valor = 'SC'
      elsif self.aprobado?
        valor = 'A'
      else
        valor = 'AP'
      end
    else
      if final_o_posterior.eql? 'F'
        valor = colocar_nota_final
      elsif final_o_posterior.eql? 'P'  
        valor = colocar_nota_posterior
      else
        valor = colocar_nota
      end
    end
    valor += " (#{self.tipo_calificacion_id})" if incluir_tipo and self.tipo_calificacion_id  and !self.retirado?
    return valor
  end

  def colocar_nota_final
    if retirado? 
      return '--'
    elsif self.calificacion_final.nil?
      return 'SN'
    elsif asignatura.absoluta? or self.asignatura.forzar_absoluta
      if self.aprobado?
        valor = 'A'
      else
        valor = 'AP'
      end     
    else
      return sprintf("%02i", self.calificacion_final)
    end   
  end

  def colocar_nota_posterior
    if self.calificacion_posterior.nil?
      return 'SN'
    else
      return sprintf("%02i", self.calificacion_posterior)
    end   
  end

  def tiene_calificacion_posterior?
    (self.reparacion? || self.diferido?) and self.calificacion_posterior
  end

  def colocar_nota
    if self.tiene_calificacion_posterior?
      return self.colocar_nota_posterior
    else
      return self.colocar_nota_final
    end
  end

  def tipo_calificacion_to_cod
    tipo = ''
    if retirado?
      tipo = 'RT'
    elsif pi?
      tipo = PI
    elsif calificacion_final.nil?
      tipo = 'PD'
    else

      if reparacion?
        tipo = calificacion_final.to_i > 9 ? 'RA' : 'RR'
      else
        tipo = calificacion_final.to_i > 9 ? 'NF' : 'AP'
      end
    end
    return tipo
  end

  def calificacion_en_letras particular = nil

    valor = ''
    if retirado?
      valor = 'RETIRADO'
    elsif pi?
      valor = 'PÉRDIDA POR INASISTENCIA'
    elsif  sin_calificar?
      valor = 'POR DEFINIR'
    elsif asignatura.absoluta? or self.asignatura.forzar_absoluta
      valor = self.estado.upcase
    else
      calificacion = (diferido? || reparacion? || particular.eql?('posterior')) ? calificacion_posterior : calificacion_final
      valor = num_a_letras calificacion
    end
    return valor
  end

  def num_a_letras num
    numeros = %W(CERO UNO DOS TRES CUATRO CINCO SEIS SIETE OCHO NUEVE DIEZ ONCE DOCE TRECE CATORCE QUINCE)

    return 'CALIFICACIÓN PENDIENTE' if num.nil? or !(num.is_a? Integer or num.is_a? Float)
    num = num.to_i
      
    if num < 10 
      return "#{numeros[0]} #{numeros[num]}"
    elsif num >= 10  and num < 16
      return numeros[num]
    elsif num >= 16 and num < 20
      aux = num % 10
      return "#{numeros[10]} Y #{numeros[aux]}"
    elsif num == 20
      return 'VEINTE'
    else
      return 'CALIFICACIÓN PENDIENTE'
    end
    

  end

  def nombre_estudiante_con_retiro
    aux = estudiante.usuario.apellido_nombre
    aux += " (retirado)" if retirado? 
    return aux
  end

  def nombre_estudiante_con_retiro_plus
    aux = "#{estudiante.usuario.apellido_nombre}"
    aux += " <div class='badge badge-info'>Retirada</div>" if retirado? 
    return aux
  end


  # def retirada?
  #   # return (cal_tipo_estado_inscripcion_id.eql? RETIRADA) ? true : false
  #   tipo_estado_inscripcion_id.eql? RETIRADA
  # end
 
  def inscrita_como_pci?
    self.escuela_id and self.escuela_id.eql? seccion.escuela.id ? false : true
  end

  def calificar valor

    if valor.eql? 'RT'
      self.estado = :retirado
      self.tipo_calificacion_id = TipoCalificacion::FINAL 
    elsif self.asignatura and self.asignatura.absoluta?
      if valor.eql? 'A'
        self.estado = :aprobado
      else
        self.estado = :aplazado
      end
      self.tipo_calificacion_id = TipoCalificacion::FINAL
    else
      self.calificacion_final = valor
      
      if self.calificacion_final >= 10
        self.estado = :aprobado
      else
        if self.calificacion_final == 0
          self.tipo_calificacion_id = TipoCalificacion::PI 
        else
          self.tipo_calificacion_id = TipoCalificacion::FINAL 
        end
        self.estado = :aplazado
      end
    end
  end


  protected

  def destroy_inscripcionescuelaperiodo
    self.inscripcionescuelaperiodo.destroy if (inscripcionescuelaperiodo and !inscripcionescuelaperiodo.inscripcionsecciones.any?)
  end

  def actualizar_estados
    actualizar_estado_grado
    # OJO: REVISAR ESTA ACTUALIZACIÓN. CREO QUE DEBERÍA COLOCARSE ANTES DE VALIDAR (before_validate)
    # agregar_inscripcionescuelaperiodo
  end

  def agregar_inscripcionescuelaperiodo
    if self.inscripcionescuelaperiodo.nil?
      escupe = Escuelaperiodo.where(periodo_id: self.periodo.id, escuela_id: self.escuela_id).first
      
      unless aux = Inscripcionescuelaperiodo.where(estudiante_id: self.estudiante_id, escuelaperiodo_id: escupe.id).first

        aux = Inscripcionescuelaperiodo.create(estudiante_id: self.estudiante_id, escuelaperiodo_id: escupe.id, tipo_estado_inscripcion_id: TipoEstadoInscripcion::INSCRITO, grado_id: self.grado_id)
      end
      self.inscripcionescuelaperiodo_id = aux.id

    end
  end


  def set_escuela_default
    self.escuela_id = estudiante.escuelas.first.id if (escuela_id.nil? and estudiante and estudiante.escuelas.count == 1)
  end

  def set_estados
    self.tipo_calificacion_id ||= FINAL
    if self.retirado?
      self.calificacion_final = nil
    elsif self.asignatura and self.asignatura.absoluta?
      self.primera_calificacion = nil
      self.segunda_calificacion = nil
      self.tercera_calificacion = nil
      self.calificacion_final = self.aprobado? ? 20 : 1
      self.calificacion_posterior = nil
      self.tipo_calificacion_id = TipoCalificacion::FINAL
    elsif self.pi?
      self.estado = :aplazado
      self.primera_calificacion = nil
      self.segunda_calificacion = nil
      self.tercera_calificacion = nil
      self.calificacion_final = 1
      self.calificacion_posterior = nil
    elsif self.calificacion_posterior

      if self.calificacion_posterior.to_i >= 10
        self.estado = :aprobado
      else
        self.estado = :aplazado
      end
    elsif self.calificacion_final
      if self.calificacion_final.to_i >= 10
        self.tipo_calificacion_id ||= FINAL
        self.calificacion_posterior = nil
        self.estado = :aprobado
      else
        self.estado = :aplazado
      end
    elsif self.asignatura and self.asignatura.numerica3?
      if self.segunda_calificacion
        self.estado = :trimestre2
      elsif self.primera_calificacion
        self.estado = :trimestre1
      end
    end

    if self.calificacion_final && self.calificacion_final.to_i >= 10
      self.tipo_calificacion_id = FINAL
      self.calificacion_posterior = nil
      self.estado = :aprobado
    end
    self.set_escuela_default
    
    self.pci = self.inscrita_como_pci?

    agregar_inscripcionescuelaperiodo
  end

  def calcular_numeros_del_grado
    self.grado.update(eficiencia: self.grado.calcular_eficiencia, promedio: self.grado.calcular_promedio, ponderado: self.calcular_ponderado)
  end

  def actualizar_estado_grado
    if asignatura.tipoasignatura_id.eql? Tipoasignatura::PROYECTO and self.grado

      if self.sin_calificar?
        self.grado.update(estado: 1, culminacion_periodo_id: nil)
      elsif self.retirado? or self.aplazado?
        self.grado.update(estado: 0, culminacion_periodo_id: nil)
      elsif self.aprobado?
        self.grado.update(estado: 2, culminacion_periodo_id: periodo.id)
      end
    end
    return true
  end

  def set_default
    self.tipo_calificacion_id ||= FINAL
  end

  def set_bitacora
    Bitacora.create!(
      descripcion: seccion.descripcion_escuela, 
      tipo: Bitacora::ELIMINACION,
      usuario_id: self.estudiante_id,
      id_objeto: self.id,
      tipo_objeto: self.class.name,
      ip_origen: nil
    )
  end

  private

  def self.import row, fields, current_usuario_id, current_ip

    # fields[:periodo_id]
    # fields[:escuela_id]

    total_newed = total_updated = 0
    no_registred = nil

    # BUSCAR PERIODO
    if row[3]
      row[3].strip!
      row[3].upcase!
    end
    row[3] = fields[:periodo_id] if row[3].blank?

    p "      ROW: #{row}     ".center(400, '#')

    if periodo = Periodo.where(id: row[3]).first
      p "      PERIODO: #{periodo.id}     ".center(400, '$')
      # LIMPIAR CI
      if row[0]
        row[0].strip!
        row[0].delete! '^0-9'
      else
        return [0,0,'error en ci']
      end

      # LIMPIAR CODIGO ASIGNATURA
      if row[1]
        row[1].strip!
      else
        return [0,0,'error en código asignatura']
      end

      asignatura = Asignatura.where(id: row[1]).first
      asignatura ||= Asignatura.where(id: "0#{row[1]}").first

      if !asignatura.nil?
        p "      ASIGNATURA: #{asignatura.id}     ".center(400, '$')
        seccion = asignatura.secciones.where(periodo_id: periodo.id, numero: row[2]).first

        if seccion.nil?
          seccion = asignatura.secciones.create!(numero: row[2], periodo_id: periodo.id, tipo_seccion_id: 'NF')
        end

        if seccion
          p "      SECCIÓN: #{seccion.id}     ".center(400, '$')
          if estudiante = Estudiante.where(usuario_id: row[0]).first

            if grado = estudiante.grados.where(escuela_id: fields[:escuela_id]).first
              p "      GRADO: #{grado.id}     ".center(400, '$')
              if inscripcion = seccion.inscripcionsecciones.where(estudiante_id: estudiante.ci).first
                nuevo = false
                p "      USADO 🤭     ".center(400, '$')

              else
                p "      NUEVO     ".center(400, '$')

                nuevo = true
                escuelaperiodo = Escuelaperiodo.where(periodo_id: periodo.id, escuela_id: fields[:escuela_id]).first
                escuelaperiodo ||= Escuelaperiodo.create!(periodo_id: periodo.id, escuela_id: fields[:escuela_id])
                p "      ¡ESCUELA PERIODO CREADA O ENCONTRADA!     ".center(400, '$')


                # BUSCAR O CREAR INSCRIPCIÓN_ESCUELA_PERIODO
                inscrip_escuela_period = estudiante.inscripcionescuelaperiodos.where(escuelaperiodo_id: escuelaperiodo.id).first

                inscrip_escuela_period ||= Inscripcionescuelaperiodo.create!(estudiante_id: estudiante.ci, escuelaperiodo_id: escuelaperiodo.id, tipo_estado_inscripcion_id: 'INS', grado_id: grado.id)

                inscripcion = Inscripcionseccion.new
                inscripcion.inscripcionescuelaperiodo_id = inscrip_escuela_period.id

                inscripcion.estudiante_id = estudiante.ci
                inscripcion.escuela_id = fields[:escuela_id]
                inscripcion.seccion_id = seccion.id
                inscripcion.grado_id = grado.id

              end

              if row[4] and !row[4].blank?
                # row[4].strip!
                inscripcion.calificar row[4]
                p "      CALIFICANDO ANDO!     ".center(400, '$')
              end

              if inscripcion.save!
                p "      INSCRIPCIÓN GUARDADA!     ".center(400, '$')

                if nuevo
                  total_newed = 1
                  desc_us = "Inscripción de Usuario (#{current_usuario_id}) vía migración."
                  tipo_us = Bitacora::CREACION
                else
                  total_updated = 1
                  desc_us = "Actualización de Inscripción del usuario (#{current_usuario_id}) vía migración."
                  tipo_us = Bitacora::ACTUALIZACION
                end

                Bitacora.create!(
                  descripcion: desc_us, 
                  tipo: tipo_us,
                  usuario_id: current_usuario_id,
                  comentario: nil,
                  id_objeto: inscripcion.id,
                  tipo_objeto: 'Inscripcionseccion',
                  ip_origen: current_ip
                )

              else
                no_registred = 'no fue posible guardar el registro'
              end
            else
              no_registred = 'grado no asociado'
            end
          else
            no_registred = 'no se pudo encontrar el estudiante'
          end
        else
          no_registred = 'no se pudo crear o encontrar la sección'
        end
      else
        no_registred = 'asignatura no encontrada'
      end
    else
      no_registred = 'periodo no encontrado'
    end

    [total_newed, total_updated, no_registred]
  end
end
