class School < ApplicationRecord
  # ASSOCIATIONS
  belongs_to :period_active, foreign_key: 'period_active_id', class_name: 'Period', optional: true
  belongs_to :period_enroll, foreign_key: 'period_enroll_id', class_name: 'Period', optional: true
  belongs_to :faculty

  has_many :areas
  has_many :subjects, through: :areas
  has_many :admins, as: :env_authorizable 

  has_many :academic_processes

  has_many :periods, through: :academic_processes

  accepts_nested_attributes_for :areas, :academic_processes, :periods

  # ENUMERATIONS:
  enum type_entity: [:pregrado, :postgrado]

  # VALIDATIONS
  validates :code, presence: true
  validates :name, presence: true

end
