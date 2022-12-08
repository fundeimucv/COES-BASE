class Period < ApplicationRecord
	# ENUMS:
	enum modality: [:I, :II, :U, :E]

	# VALIDATIONS:
	validates :year, presence: true
	validates :year, numericality: {only_integer: true, greater_than_or_equal_to: 1920, less_than_or_equal_to: 2100}
	validates :modality, presence: true

	def name
		"#{year}-#{modality.upcase}"
	end

end
