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

  # ASSOCIATIONS:
  belongs_to :student, primary_key: :user_id
  belongs_to :study_plan
  belongs_to :admission_type
  has_one :school, through: :study_plan
  
  has_many :enroll_academic_processes
  # has_many :academic_records, through: :enroll_academic_processes

  has_many :payment_reports, as: :payable

  # ENUMERIZE:
  enum registration_status: [:universidad, :facultad, :escuela]
  enum graduate_status: [:no_graduable, :tesista, :posible_graduando, :graduando, :graduado]

  # VALIDATIONS:
  # validates :student, presence: true
  validates :study_plan, presence: true
  validates :admission_type, presence: true

  validates_uniqueness_of :study_plan, scope: [:student], message: 'El estudiante ya tiene el grado asociado', field_name: false

  # FUNCTIONS:

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

  after_initialize do
    if new_record?
      self.study_plan_id ||= StudyPlan.first.id
    end
  end  

end
