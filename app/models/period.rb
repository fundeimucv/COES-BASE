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

	# SCOPE:
	scope :by_name, -> (year, code) {joins(:period_type).where(year: year, 'period_type.code': code)}
	scope :find_by_name, -> (name) {joins(:period_type).where(year: name.split('-').first, 'period_type.code': name.split('-').last)}



	def name_revert
		"#{period_type.code.upcase}#{year}" if period_type
	end

	def name
		"#{year}-#{period_type.code.upcase}" if period_type
	end

  rails_admin do
    navigation_label 'Inscripciones'
    navigation_icon 'fa-solid fa-clock'

    edit do
    	fields :year, :period_type
    end

    export do
    	fields :year, :period_type
    end
  end

end
