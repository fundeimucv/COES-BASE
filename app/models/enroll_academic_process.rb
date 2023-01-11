class EnrollAcademicProcess < ApplicationRecord
  # SCHEMA:
  # t.bigint "grade_id", null: false
  # t.bigint "academic_process_id", null: false
  # t.integer "enroll_status"
  # t.integer "permanence_status"

  # ASSOCIATIONS:
  belongs_to :grade
  belongs_to :academic_process
  has_many :payment_reports, as: :payable

  # ENUMERIZE:
  enum enroll_status: [:preinscrito, :reservado, :confirmado, :retirado]
  enum permanence_status: [:nuevo, :regular, :reincorporado, :articulo3, :articulo6, :articulo7]  

  # VALIDATIONS:
  validates :grade, presence: true
  validates :academic_process, presence: true
  validates :enroll_status, presence: true
  validates :permanence_status, presence: true

  rails_admin do
    navigation_label 'Inscripciones'
    navigation_icon 'fa-solid fa-calendar-check'
  end

end
