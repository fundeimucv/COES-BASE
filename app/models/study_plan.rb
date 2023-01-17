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

  def desc
    "(#{code}) #{name}"
  end

  rails_admin do
    navigation_label 'Gestión Académica'
    navigation_icon 'fa-solid fa-award'

    export do
      fields :code, :name
    end

  end

end
