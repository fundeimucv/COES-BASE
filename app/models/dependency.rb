class Dependency < ApplicationRecord
  # belongs_to :subject
  belongs_to :subject_parent, class_name: 'Subject', foreign_key: :subject_parent_id
  belongs_to :subject_dependent, class_name: 'Subject', foreign_key: :subject_dependent_id

  validates_uniqueness_of :subject_parent_id, scope: [:subject_dependent_id], message: 'la relación ya existe', field_name: false
  validates :subject_parent_id, presence: true
  validates :subject_dependent_id, presence: true

  validates_with NestedDependencyValidator, field_name: false  
end
