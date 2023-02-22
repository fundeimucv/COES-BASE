class StudentSessionController < ApplicationController
	before_action :set_session_id_if_multirols, only: [:dashboard]
	before_action :authenticate_student!

	def dashboard
		# session[:student_id] ||= current_user.id
	end
end
