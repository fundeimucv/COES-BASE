class TeacherSessionController < ApplicationController
	before_action :set_session_id_if_multirols, only: [:dashboard]
	before_action :authenticate_teacher!

	def dashboard
	end

end
