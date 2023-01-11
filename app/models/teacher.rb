class Teacher < ApplicationRecord
  # SCHEMA:
  # t.bigint "area_id", null: false

  # ASSOCIATIONS:
  belongs_to :user
  belongs_to :area
  # has_and_belongs_to_many :secondary_teachers, class_name: 'SectionTeacher'

  # VALIDATIONS:
  validates :area, presence: true
  validates :user, presence: true

  def name
    self.user.name if self.user
  end

  rails_admin do
    navigation_label 'Gestión de Usuarios'
    navigation_icon 'fa-regular fa-chalkboard-user'    
  end
end
