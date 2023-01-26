class Teacher < ApplicationRecord
  # SCHEMA:
  # t.bigint "area_id", null: false

  # ASSOCIATIONS:
  belongs_to :user
  accepts_nested_attributes_for :user

  belongs_to :area
  # accepts_nested_attributes_for :area
  # has_and_belongs_to_many :secondary_teachers, class_name: 'SectionTeacher'

  has_many :sections

  # VALIDATIONS:
  validates :area, presence: true
  validates :user, presence: true, uniqueness: true

  def name
    self.user.name if self.user
  end

  # CALLBACKS:
  after_destroy :check_user_for_destroy
  
  # HOOKS:
  def check_user_for_destroy
    user_aux = User.find self.user_id
    user_aux.delete if user_aux.without_rol?
  end  

  def description
    if user
      aux = user.description
      aux += " - #{area.name}" if area
    else
      aux = 'Sin descripción'
    end
    return aux
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

    import do
      fields :user_id, :area_id
    end
  end
end
