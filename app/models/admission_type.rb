class AdmissionType < ApplicationRecord
  # SCHEMA:
  # t.string "name"
  # t.bigint "school_id", null: false

  #ASSOCIATIONS:
  belongs_to :school
  has_many :grades, dependent: :destroy
  has_many :students, through: :grades

  #VALIDATIONS:
  validates :name, presence: true

  rails_admin do
    navigation_label 'Gestión de Usuarios'
    navigation_icon 'fa-regular fa-user-tag'

    list do
      fields :name, :school

      field :total_students do
        label 'Total Estudiantes'
      end

      field :created_at
    end

    show do
      fields :name, :school
    end

    edit do
      fields :name, :school
    end
  end

  def total_students
    students.count
  end

end
