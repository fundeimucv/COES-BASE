class Section < ApplicationRecord
  # SCHEMA:
  # t.string "code"
  # t.integer "capacity"
  # t.bigint "course_id", null: false
  # t.bigint "teacher_id", null: false
  # t.boolean "qualified"
  # t.integer "modality"
  # t.boolean "enabled"

  # ASSOCIATIONS:
  # belongs_to
  belongs_to :course
  belongs_to :teacher, optional: true

  # has_one
  has_one :subject, through: :course
  has_one :academic_process, through: :course
  has_one :period, through: :academic_process
  has_one :school, through: :academic_process

  # has_many
  has_many :academic_records, dependent: :destroy
  has_many :enroll_academic_process, through: :academic_records
  has_many :grades, through: :enroll_academic_process
  has_many :students, through: :grades

  # has_and_belongs_to_namy
  has_and_belongs_to_many :secondary_teachers, class_name: 'SectionTeacher'

  #ENUMERIZE:
  enum modality: [:"equivalencia_externa", :"equivalencia_interna", :diferido, :"nota_final", :reparación, :suficiencia]


  # VALIDATIONS:
  validates :code, presence: true
  validates :capacity, presence: true
  validates :course, presence: true

  rails_admin do
    navigation_label 'Inscripciones'
    navigation_icon 'fa-solid fa-list'
  end

end
