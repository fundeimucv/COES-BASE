class Admin < ApplicationRecord
  # SCHEMA:
  # t.bigint "user_id", null: false
  # t.integer "role"
  # t.string "env_authorizable_type", default: "Faculty"
  # t.bigint "env_authorizable_id"

  # ENUMERIZE:
  enum role: [:super, :jefe_control_estudio, :director, :jefe_departamento, :asistente]

  # ASSOCIATIONS:
  belongs_to :user
  belongs_to :env_authorizable, polymorphic: true
  belongs_to :profile, optional: true

  # VALIDATIONS:
  validates :env_authorizable, presence: true
  validates :user, presence: true
  validates :role, presence: true

  # validates :env_authorizable_type, presence: true

  rails_admin do
    navigation_label 'Gestión de Usuarios'
    navigation_icon 'fa-regular fa-user-tie'

    list do
      fields :user, :role, :env_authorizable, :created_at
    end

    edit do
      fields :user, :role, :env_authorizable

      # field :role do
      #   html_attributes do
      #     {:onChange => "alert($(this).val())"}

      #   end
      # end
    end
  end
end
