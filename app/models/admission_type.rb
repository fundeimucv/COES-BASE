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
  end

end
