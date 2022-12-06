class Area < ApplicationRecord

  # ASSOCITATIONS:
  belongs_to :school
  belongs_to :parent_area, optional: true, class_name: 'Area'
  has_many :subareas, class_name: 'Area'
  has_many :subjects
  accepts_nested_attributes_for :subjects

  # VALIDATIONS:
  validates :name, presence: true
  validates :school_id, presence: true

end
