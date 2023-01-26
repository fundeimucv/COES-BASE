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

  has_many :bank_accounts
  accepts_nested_attributes_for :bank_accounts
  has_many :admission_types
  accepts_nested_attributes_for :admission_types

  has_many :academic_processes
  has_many :areas
  has_many :study_plans
  accepts_nested_attributes_for :study_plans

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

  # CALLBAKCS:
  after_initialize :set_unique_faculty

  # HOOKS:
  def set_unique_faculty
    self.faculty_id = Faculty.first.id if Faculty.count.eql? 1
  end
  # FUNCTIONS:
  def description
    "#{self.code}: #{self.name}. (#{self.faculty.name}) #{self.type_entity.titleize}"
  end

  rails_admin do
    navigation_label 'Gestión Académica'
    navigation_icon 'fa-regular fa-school'

    list do
      fields :code, :name, :faculty, :type_entity
    end

    show do
      field :description
      fields :study_plans, :period_enroll, :period_active, :periods, :areas, :bank_accounts
    end

    edit do
      fields :faculty, :code, :name, :type_entity, :bank_accounts, :study_plans, :admission_types
    end

    export do
      fields :code, :name, :type_entity
    end
  end

end
