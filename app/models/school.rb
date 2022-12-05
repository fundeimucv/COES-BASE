class School < ApplicationRecord
  # ASSOCIATIONS
  belongs_to :period_active, foreign_key: 'period_active_id', class_name: 'Period', optional: true
  belongs_to :period_enroll, foreign_key: 'period_enroll_id', class_name: 'Period', optional: true
  has_many :areas
  accepts_nested_attributes_for :areas
  has_many :subjects, through: :areas

  validates :code, presence: true
  validates :name, presence: true

end
