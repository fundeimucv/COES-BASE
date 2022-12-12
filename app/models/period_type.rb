class PeriodType < ApplicationRecord
	# SCHEMA:
	# t.string "code"
    # t.string "name"

	# ASSOCIATIONS:
	has_many :periods

	# VALIDATIONS:
	validates :code presence: true
	validates :name presence: true
end
