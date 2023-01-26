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

  # CALLBACKS:
  after_initialize :set_unique_school
  # FUNTIONS:
  def desc
    "(#{code}) #{name}"
  end

  rails_admin do
    navigation_label 'Gestión Académica'
    navigation_icon 'fa-solid fa-award'

    export do
      fields :code, :name
    end

    edit do
      field :school
      field :code do 
        html_attributes do
          {:length => 8, :size => 8, :onInput => "$(this).val($(this).val().toUpperCase().replace(/[^a-zA-Z0-9\u00f1\u00d1 ]/g,''))"}
        end
      end
      field :name
    end

  end

  def set_unique_school
    self.school_id = School.first.id if School.count.eql? 1
  end

end
