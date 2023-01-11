class AcademicRecord < ApplicationRecord
  #SCHEMA:
  # t.bigint "section_id", null: false
  # t.bigint "enroll_academic_process_id", null: false
  # t.float "first_q"
  # t.float "second_q"
  # t.float "third_q"
  # t.float "final_q"
  # t.float "post_q"
  # t.integer "status_q"
  # t.integer "type_q"

  #ENUMERIZE:

  # enum type_q: [:sin_calificar, :aprobado, :aplazado, :retirado, :trimestre1, :trimestre2]
  # enum type_q: [:diferido, :final, :reparacion, :perdida_por_inasistencia, :parcial]
  enum type_q: [:sc, :a, :ap, :re, :t1, :t2]
  enum type_q: [:nd, :nf, :rep, :pi, :par]

  # ASSOCIATIONS:
  belongs_to :section
  belongs_to :enroll_academic_process

  has_one :academic_process, through: :enroll_academic_process
  has_one :period, through: :academic_process

  #VALIDATIONS:
  validates :section, presence: true
  validates :enroll_academic_process, presence: true
  validates :type_q, presence: true
  validates :status_q, presence: true

  rails_admin do
    navigation_label 'Inscripciones'
    navigation_icon 'fa-solid fa-signature'
  end  

end
