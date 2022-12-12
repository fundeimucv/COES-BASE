class Bank < ApplicationRecord
	# SCHEMA:
    # t.string "code"
    # t.string "name"	

	# ASSOCIATION:
	has_many :payment_reports

	# VALIDATIONS:
	valdiates :code, presence: true 
	valdiates :name, presence: true 
end
