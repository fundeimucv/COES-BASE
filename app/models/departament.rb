class Departament < ApplicationRecord
	# ASSOCIATIONS:
	belongs_to :school
	has_and_belongs_to_many :areas
	has_many :areas#, dependent: :restrict_with_error
	
	# VALIDATIONS:
	validates :name, presence: true#, uniqueness: {case_sensitive: false}

	validates_uniqueness_of :name, scope: [:school_id], message: 'Ya se tiene un departamento con ese nombre para la escuela', field_name: false, case_sensitive: false

	validates :school, presence: true


	rails_admin do
		visible do
			bindings[:controller].current_user&.admin&.authorized_read? 'Subject'
		end

		navigation_label 'Config General'
		navigation_icon 'fa-regular fa-landmark-dome'
		weight 0

		edit do

			field :name do
				html_attributes do
					{:onInput => "$(this).val($(this).val().toUpperCase())"}
				end				
			end			
			field :school do
				inline_edit false 
			end
		end

		update do

			field :name do
				html_attributes do
					{:onInput => "$(this).val($(this).val().toUpperCase())"}
				end				
			end			
			field :school do
				inline_edit false 
			end
			field :areas do
				inline_add false
			end
		end

		list do
			fields :name, :school, :areas
		end
	end

end
