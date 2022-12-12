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
  has_many :payment_reports, as: :payable

  # ENUMERIZE:
  enum registration_status: [:universidad, :facultad, :escuela]
  enum graduate_status: [:no_graduable, :tesista, :posible_graduando, :graduando, :graduado]

  # VALIDATIONS:
  validates :student, presence: true
  validates :study_plan, presence: true
  validates :admission_type, presence: true

end
