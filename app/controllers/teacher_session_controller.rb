class TeacherSessionController < ApplicationController
	before_action :set_session_id_if_multirols, only: [:dashboard]
	before_action :authenticate_teacher!

	layout 'logged'

	def dashboard
		@teacher = current_teacher
		@title = "Sessión del Profesor #{@teacher.user_description}"
	end

end
