class AdmissionType < ApplicationRecord
  # SCHEMA:
  # t.string "name"
  # t.bigint "school_id", null: false

  #ASSOCIATIONS:
  belongs_to :school
  has_many :grades, dependent: :destroy
  has_many :students, through: :grades

  #VALIDATIONS:
  validates :name, presence: true, uniqueness: true

  rails_admin do
    navigation_icon 'fa-regular fa-user-tag'

    list do
      field :name
      field :school

      field :total_students do
        label 'Total Estudiantes'
      end

      field :created_at
    end

    show do
      field :name
      field :school
    end

    edit do
      field :name
      field :school
    end

    export do
      fields :name
    end
  end

  def total_students
    students.count
  end

end
