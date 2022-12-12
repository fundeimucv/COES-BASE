class AcademicProcess < ApplicationRecord
  # SCHEMA:
    # t.bigint "school_id", null: false
    # t.bigint "period_id", null: false
    # t.integer "max_credits"
    # t.integer "max_subjects"

  # ASSOCIATIONS:
  #belongs_to:
  belongs_to :school
  belongs_to :period

  #has_many:
  has_many :enroll_academic_processes, dependent: :destroy
  has_many :grades, through: :enroll_academic_processes
  has_many :students, through: :grades

  #VALIDATIONS:
  validates :school, presence: true
  validates :period, presence: true
  validates :max_credits, presence: true
  validates :max_subjects, presence: true

end
