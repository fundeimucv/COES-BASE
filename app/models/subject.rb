class Subject < ApplicationRecord
  # ASSOCIATIONS:
  belongs_to :area
  has_one :school, through: :area

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
  validates :area_id, presence: true

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
