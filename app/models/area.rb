class Area < ApplicationRecord
  belongs_to :school
  belongs_to :area, optional: true

  has_many :subareas, class_name: 'Area'

  has_many :subjects
  accepts_nested_attributes_for :subjects

  validates :name, presence: true

end
