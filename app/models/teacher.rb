class Teacher < ApplicationRecord
  # SCHEMA:
  # t.bigint "area_id", null: false

  # ASSOCIATIONS:
  belongs_to :user
  belongs_to :area
  # has_and_belongs_to_many :secondary_teachers, class_name: 'SectionTeacher'

  has_many :sections

  # VALIDATIONS:
  validates :area, presence: true
  validates :user, presence: true, uniqueness: true

  def name
    self.user.name if self.user
  end

  rails_admin do
    navigation_label 'Gestión de Usuarios'
    navigation_icon 'fa-regular fa-chalkboard-user'

    list do
      exclude_fields :updated_at
    end

    show do
      fields :user, :area, :sections
    end

    edit do
      fields :user, :area
    end

    export do
      fields :user, :area, :created_at
    end

  end
end
