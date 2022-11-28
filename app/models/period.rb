class Period < ApplicationRecord
	enum modality: [:Semestral, :Especial, :Intensivo, :Único]

  validates :year, presence: true
  validates :year, numericality: {only_integer: true, greater_than_or_equal_to: 1920, less_than_or_equal_to: 2200}

  validates :modality, presence: true
  
  validates :name, presence: true
  validates :name, length: {maximum: 3}

end
