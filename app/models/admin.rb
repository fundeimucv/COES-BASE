class Admin < ApplicationRecord
  # SCHEMA:
  # t.bigint "user_id", null: false
  # t.integer "role"
  # t.string "env_authorizable_type", default: "Faculty"
  # t.bigint "env_authorizable_id"

  # ENUMERIZE:
  enum role: [:ninja, :super, :admin_escuela, :admin_departamento, :taquilla, :jefe_control_estudio]

  # ASSOCIATIONS:
  belongs_to :user
  belongs_to :env_authorizable, polymorphic: true
  belongs_to :profile, optional: true

  # VALIDATIONS:
  validates :env_authorizable, presence: true
  validates :user, presence: true
  validates :role, presence: true

  # validates :env_authorizable_type, presence: true
end
