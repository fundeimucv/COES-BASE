class Admin < ApplicationRecord
  
  # ASSOCIATIONS:
  belongs_to :user
  belongs_to :env_authorizable, polymorphic: true

  # VALIDATIONS:
  validates :env_authorizable_id, presence: true
  validates :env_authorizable_type, presence: true  

  enum role: [:ninja, :super, :admin_escuela, :admin_departamento, :taquilla, :jefe_control_estudio]
end
