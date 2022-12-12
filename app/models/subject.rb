class Subject < ApplicationRecord
  # SCHEMA:
  # t.string "code", null: false
  # t.string "name", null: false
  # t.boolean "active", default: true
  # t.integer "unit_credits", default: 24, null: false
  # t.integer "ordinal", default: 0, null: false
  # t.integer "qualification_type"
  # t.integer "modality"
  # t.bigint "area_id", null: false  

  # ASSOCIATIONS:
  belongs_to :area
  has_one :school, through: :area

  has_many :courses

  # ENUMS:
  enum qualification_type: [:numerica, :absoluta, :parcial3]
  enum modality: [:obligatoria, :electiva, :optativa, :proyecto] 

  # VALIDATIONS:
  validates :code, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true
  validates :ordinal, presence: true
  validates :modality, presence: true
  validates :qualification_type, presence: true
  validates :unit_credits, presence: true
  validates :area, presence: true

  def modality_initial
    case modality
    when :obligatoria
      'OB'
    when :electiva
      'E'
    when :optativa
      'OP'
    when :proyecto
      'P'
    end      
  end

end
