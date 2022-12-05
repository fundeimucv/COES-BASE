class Subject < ApplicationRecord
  # ASSOCIATIONS:
  belongs_to :area
  has_one :school, through: :area

  # ENUMS:
  enum qualification_type: [:Numerica, :Absoluta, :Parcial3]
  enum modality: [:Electiva, :Obligatoria, :Optativa, :Proyecto] 

  # VALIDATIONS:
  validates :code, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true
  validates :ordinal, presence: true
  validates :modality, presence: true
  validates :qualification_type, presence: true
  validates :unit_credits, presence: true
  validates :area_id, presence: true

end
