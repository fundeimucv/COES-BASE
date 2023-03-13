class Grade < ApplicationRecord
  # SCHEMA:
  # t.bigint "student_id", null: false
  # t.bigint "study_plan_id", null: false
  # t.integer "graduate_status"
  # t.bigint "admission_type_id", null: false
  # t.integer "registration_status"
  # t.float "efficiency"
  # t.float "weighted_average"
  # t.float "simple_average"
  # t.datetime "appointment_time"
  # t.integer "duration_slot_time"

  # ASSOCIATIONS:
  belongs_to :student, primary_key: :user_id
  belongs_to :study_plan
  belongs_to :admission_type
  has_one :school, through: :study_plan
  
  has_many :enroll_academic_processes, dependent: :destroy
  has_many :academic_processes, through: :enroll_academic_processes
  has_many :academic_records, through: :enroll_academic_processes

  has_many :payment_reports, as: :payable, dependent: :destroy

  # ENUMERIZE:
  enum registration_status: [:universidad, :facultad, :escuela]
  enum graduate_status: [:no_graduable, :tesista, :posible_graduando, :graduando, :graduado]

  #SCOPES:
  scope :with_day_enroll_eql_to, -> (day){ where(appointment_time: day.all_day)}
  scope :with_appointment_time, -> { where("appointment_time IS NOT NULL")}
  scope :with_appointment_time_eql_to, -> (dia){ where("date(appointment_time) = '#{dia}'")}
  scope :without_appointment_time, -> { where(appointment_time: nil)}

  # scope :with_enrollments_in_period, -> (period_id) { joins(academic_records: {section: {course: :academic_process}}).where('(SELECT COUNT(*) FROM academic_records WHERE academic_records.estudiante_id = grades.student_id) > 0 and secciones.periodo_id = ?', periodo_id) }

  # scope :with_enrollments_in_period, -> (period_id) { joins(academic_records: {section: {course: :academic_process}}).where('(SELECT COUNT(*) FROM academic_records WHERE academic_records.enroll_academic_process_id = enroll_academic_processes.id) > 0 and academic_processes.period_id = ?', period_id) }

  # scope :with_enrollments_in_period, -> (period_id) { joins(academic_records: {section: {course: :academic_process}}).where('academic_processes.period_id = ?', period_id).group(:'enroll_academic_processes.id').having('COUNT(*) > 0').count}

  # ATENCIÓN: EL UNIQ DEBO HACERLO EN EL LLAMADO DEL SCOPE ANTERIOR YA QUE DE LO CONTRARIO DEVUELVE LA CANTIDAD DE REGISTROS VINCULADOS A LAS enroll_academic_processes
  scope :enrolled_in_academic_process, -> (academic_process_id) { joins(:enroll_academic_processes, :academic_processes).where('academic_processes.id': academic_process_id) }

  scope :sort_by_numbers, -> () {order([efficiency: :desc, simple_average: :desc, weighted_average: :desc])}
  
  scope :total_with_enrollments_in_period, -> (period_id) { with_enrollments_in_period(period_id).uniq.count }


  # VALIDATIONS:
  # validates :student, presence: true
  validates :study_plan, presence: true
  validates :admission_type, presence: true

  validates_uniqueness_of :study_plan, scope: [:student], message: 'El estudiante ya tiene el grado asociado', field_name: false

  # FUNCTIONS:

  def label_status_enroll_academic_process(academic_process_id)
    if iep = self.enroll_academic_processes.of_academic_process(academic_process_id).first
      iep.label_status
    else
      ApplicationController.helpers.label_status('bg-secondary', 'Sin Inscripción')
    end
  end


  def appointment_time_desc
    if (appointment_time and duration_slot_time)
      aux = ""
      aux += "#{I18n.l(appointment_time)}" if appointment_time
      aux += " | duración: #{duration_slot_time} minutos" if duration_slot_time
      return aux
    end
  end

  def user
    student.user if student
  end

  def name
    "#{study_plan.name}: #{student.name} (#{admission_type.name})" if study_plan and student and admission_type
  end

  def description
    "Plan de Estudio: #{study_plan.name}, Admitido vía: #{admission_type.name}, Estado de Inscripción: #{registration_status.titleize}" if study_plan and admission_type and registration_status
  end

  def numbers
    "Efi: #{efficiency}, Prom. Ponderado: #{weighted_average}, Prom. Simple: #{simple_average}"
    # redear una tabla descripción. OJO Sí es posible estandarizar
  end
  # RAILS_ADMIN:
  rails_admin do
    navigation_label 'Inscripciones'
    navigation_icon 'fa-solid fa-graduation-cap'

    list do
      fields :student, :study_plan, :admission_type, :registration_status, :efficiency, :weighted_average, :simple_average
    end

    show do
      field :student
      field :numbers
      field :description
      field :enroll_academic_processes
      # field :academic_records 
    end

    edit do
      fields :study_plan, :admission_type, :registration_status
    end

    export do
      fields :student, :study_plan, :admission_type, :registration_status
    end
  end


  # NUMBERSTINY:

  def total_credits_coursed periods_ids = nil
    if periods_ids
      academic_records.total_credits_coursed_on_periods periods_ids
    else
      academic_records.total_credits_coursed
    end
  end

  def total_credits_approved periods_ids = nil
    if periods_ids
      academic_records.total_credits_approved_on_periods periods_ids
    else
      academic_records.total_credits_approved
    end
  end

  def total_credits
    self.academic_records.total_credits
  end

  def update_all_efficiency

    Grados.each do |gr| 
      academic_records = gr.academic_records
      cursados = academic_records.total_credits_coursed
      aprobados = academic_records.total_credits_approved

      eficiencia = (cursados and cursados > 0) ? (aprobados.to_f/cursados.to_f).round(4) : 0.0

      aux = academic_records.coursed

      promedio_simple = aux ? aux.round(4) : 0.0

      aux = academic_records.weighted_average
      ponderado = (cursados > 0) ? (aux.to_f/cursados.to_f).round(4) : 0.0
    end

  end

  def calculate_efficiency periods_ids = nil 
        cursados = self.total_credits_coursed periods_ids
        aprobados = self.total_credits_approved periods_ids
    (cursados > 0 and aprobados != cursados) ? (aprobados.to_f/cursados.to_f).round(4) : 1.0
  end

  def calculate_average periods_ids = nil
    if periods_ids
      aux = academic_records.of_periods(periods_ids).promedio
    else
      aux = academic_records.promedio
    end

    (aux and aux.is_a? BigDecimal) ? aux.to_f.round(4) : 0.0

  end

  def calculate_weighted_average periods_ids = nil
    if periods_ids
      aux = academic_records.of_periods(periods_ids).weighted_average
    else
      aux = academic_records.weighted_average
    end
    cursados = self.total_credits_coursed periods_ids

    (cursados > 0 and aux and aux.is_a? BigDecimal) ? (aux.to_f/cursados.to_f).round(4) : 0.0
  end

  def calculate_weighted_average_approved

    aprobados = self.academic_records.total_credits_approved
    aux = self.academic_records.weighted_average_approved
    (aprobados > 0 and aux and aux.is_a? BigDecimal) ? (aux.to_f/aprobados.to_f).round(4) : 0.0
    
  end

  def calculate_average_approved
    aux = self.academic_records.promedio_approved
    (aux and aux.is_a? BigDecimal) ? aux.round(4) : 0.0
  end




  after_initialize do
    if new_record?
      self.study_plan_id ||= StudyPlan.first.id if StudyPlan.first
    end
  end  

end
