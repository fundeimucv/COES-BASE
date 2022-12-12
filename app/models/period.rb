class Period < ApplicationRecord
	#SCHEMA:
    # t.integer "year", null: false
	
	#ASSOCIATIONS:
	# belongs_to
	belongs_to :period_type

	# has_many:
	has_many :academic_processes, dependent: :destroy
	has_many :schools, through: :academic_processes
	has_many :enroll_academic_processes, through: :academic_processes

	# VALIDATIONS:
	validates :year, presence: true
	validates :year, numericality: {only_integer: true, greater_than_or_equal_to: 1920, less_than_or_equal_to: 2100}
	validates :period_type, presence: true
	validates_uniqueness_of :year, scope: [:period_type], message: 'Periodo existente', field_name: false

	def name
		"#{year}-#{period_type.code.upcase}"
	end

end
