class Period < ApplicationRecord
	enum modality: [:Semestral, :Especial, :Intensivo, :Unico]
	enum ordinal: [:I, :II]

	validates :year, presence: true
	validates :year, numericality: {only_integer: true, greater_than_or_equal_to: 1920, less_than_or_equal_to: 2200}

	validates :modality, presence: true

	validates :ordinal, presence: true
	validates :ordinal, length: {maximum: 3}

	def name
		"#{year}-#{ordinal}#{modality.first}"
	end

end
