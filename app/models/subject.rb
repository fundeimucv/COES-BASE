class Subject < ApplicationRecord
  belongs_to :area

  has_one :school, through: :area

  enum qualification_type: [:Numerica, :Absoluta, :Parcial3]
  enum modality: [:Electiva, :Obligatoria, :Optativa, :Proyecto] 


end
