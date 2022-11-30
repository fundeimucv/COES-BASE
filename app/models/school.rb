class School < ApplicationRecord
  belongs_to :period_active, foreign_key: 'period_active_id', class_name: 'Period', optional: true
  belongs_to :period_enroll, foreign_key: 'period_enroll_id', class_name: 'Period', optional: true

  validates :name, presence: true
  validates :description, presence: true

end
