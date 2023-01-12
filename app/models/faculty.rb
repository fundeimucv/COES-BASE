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
	has_one_attached :logo
	# VALIDATIONS:
	validates :code, presence: true, uniqueness: true
	validates :name, presence: true, uniqueness: true

	rails_admin do
		navigation_label 'Gestión Adadémica'
		navigation_icon 'fa-regular fa-building-columns'

		list do
			exclude_fields :created_at, :updated_at
		end

		show do
			fields :code, :name, :logo
		end


		edit do
			field :code do
				html_attributes do
					{:length => 3, :size => 3, :onInput => "$(this).val($(this).val().toUpperCase().replace(/[^A-Za-z]/g,''))"}
				end
			end
			fields :name, :logo
		end
	end
end
