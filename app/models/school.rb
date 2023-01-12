class School < ApplicationRecord
  # SCHEMA:
  # t.string "code", null: false
  # t.string "name", null: false
  # t.integer "type_entity", default: 0, null: false
  # t.boolean "enable_subject_retreat"
  # t.boolean "enable_change_course"
  # t.boolean "enable_dependents"
  # t.bigint "period_active_id"
  # t.bigint "period_enroll_id"
  
  # ASSOCIATIONS
  belongs_to :period_active, foreign_key: 'period_active_id', class_name: 'Period', optional: true
  belongs_to :period_enroll, foreign_key: 'period_enroll_id', class_name: 'Period', optional: true
  belongs_to :faculty
  belongs_to :bank_account

  has_many :admission_types
  has_many :academic_processes
  has_many :areas
  has_many :study_plans
  has_many :subjects, through: :areas
  has_many :periods, through: :academic_processes
  has_many :admins, as: :env_authorizable 

  # accepts_nested_attributes_for :areas, :academic_processes, :admission_types

  # ENUMERATIONS:
  enum type_entity: [:pregrado, :postgrado, :extension, :investigacion]

  # VALIDATIONS
  validates :type_entity, presence: true
  validates :code, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true

  def description
    "#{self.code}: #{self.name}. (#{self.faculty.name}) #{self.type_entity.titleize}"
  end

  rails_admin do
    navigation_label 'Gestión Adadémica'
    navigation_icon 'fa-regular fa-school'

    list do
      fields :code, :name, :faculty, :period_enroll, :period_active, :type_entity
    end

    show do
      field :description do
        label 'Descripción'
      end
      fields :period_enroll, :period_active, :periods, :areas
      field :bank_account
    end

    edit do
      exclude_fields :created_at, :updated_at, :enable_dependents, :areas, :subjects, :periods, :admins, :admission_types
    end
  end

end
