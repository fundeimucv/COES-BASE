class Faculty < ApplicationRecord
	#SCHEMA:
    # t.string "code"
    # t.string "name"

	# ASSOCIATIONS:
	# has_many:
	has_many :admins, as: :env_authorizable
	has_many :schools, dependent: :destroy
	has_many :academic_processes, through: :schools
	has_many :periods, through: :academic_processes
	# has_many :grades, through: :schools
	# has_many :students, through: :grades

	# VALIDATIONS:
	validates :code, presence: true, uniqueness: true
	validates :name, presence: true, uniqueness: true
end
