class StudyPlan < ApplicationRecord
  # SCHEMA:
  # t.string "code"
  # t.string "name"
  # t.bigint "school_id", null: false  


  # ASSOCIATIONS:
  belongs_to :school
  has_many :grades

  # VALIDATIONS:

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true
  validates :school, presence: true

end
