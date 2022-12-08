class Faculty < ApplicationRecord
	# ASSOCIATIONS:
	has_many :schools
	has_many :admins, as: :env_authorizable 


	# VALIDATIONS:
	validates :name, presence: true, uniqueness: true
end
