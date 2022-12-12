class Bank < ApplicationRecord
	# SCHEMA:
    # t.string "code"
    # t.string "name"	

	# ASSOCIATION:
	has_many :payment_reports

	# VALIDATIONS:
	validates :code, presence: true 
	validates :name, presence: true 
end
