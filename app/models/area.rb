class Area < ApplicationRecord
  # SCHEMA:
  # t.string "name", null: false
  # t.bigint "school_id", null: false
  # t.bigint "parent_area_id"
  
  # ASSOCITATIONS:
  belongs_to :school
  belongs_to :parent_area, optional: true, class_name: 'Area', primary_key: :parent_area_id
  has_many :admins, as: :env_authorizable 

  has_many :subareas, class_name: 'Area', foreign_key: :parent_area_id

  has_many :subjects
  accepts_nested_attributes_for :subjects

  # VALIDATIONS:
  validates :name, presence: true
  validates :school_id, presence: true

  def description
    "#{self.id}: #{self.name}"
  end

end
