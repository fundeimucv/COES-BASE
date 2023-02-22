class TeacherSessionController < ApplicationController
	before_action :authenticate_teacher!
	before_action :set_session_id_if_multirols, only: [:dashboard]

	def dashboard
	end

end
