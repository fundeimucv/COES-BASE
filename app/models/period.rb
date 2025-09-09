# == Schema Information
#
# Table name: periods
#
#  id             :bigint           not null, primary key
#  name           :string
#  year           :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  period_type_id :bigint
#
# Indexes
#
#  index_periods_on_period_type_id  (period_type_id)
#
class Period < ApplicationRecord
	
	#ASSOCIATIONS:
	# belongs_to
	belongs_to :period_type

	# has_many:
	has_many :academic_processes, dependent: :destroy
	has_many :courses, through: :academic_processes
	has_many :schools, through: :academic_processes
	has_many :enroll_academic_processes, through: :academic_processes

	# VALIDATIONS:
	validates :year, presence: true
	validates :year, numericality: {only_integer: true, greater_than_or_equal_to: 1900, less_than_or_equal_to: 2100}

	validates :period_type, presence: true
	validates_uniqueness_of :year, scope: [:period_type], message: 'Periodo existente', field_name: false

	# SCOPE:
	# scope :by_name, -> (year, code) {joins(:period_type).where(year: year, 'period_types.code': code)}

	# scope :find_by_name, -> (name) {joins(:period_type).where(year: name.split('-').first, 'period_types.code': name.split('-').last).first}

	before_save :set_name


	def name_revert
		"#{period_type&.code&.upcase}#{year}"
	end

	def get_name
		"#{year}-#{period_type&.code&.upcase}"
	end

	def period_type_name
		period_type&.name
	end

  rails_admin do
    navigation_label 'Planif. Periódica'
    navigation_icon 'fa-solid fa-clock'
    visible false

    list do 
		sort_by [:year]
		field :name
    end

    edit do
    	group :dato_periodo do
    		label 'Datos del Perido'
    		# active false
				field :year do
					a = Date.today.year
					html_attributes do
						{onInput: "$(this).val($(this).val().replace(/[^0-9]/g,''))", min: a-60, max:a+10, step: 1 }
					end  
				end
				field :period_type
			end
    end

    show do
    	fields :name
    end

    export do
    	field :name do
    		label 'Periodo'
    	end
    end
  end

  private

  def set_name
  	self.name = self.get_name
  end

end
