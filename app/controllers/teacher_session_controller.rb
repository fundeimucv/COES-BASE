class TeacherSessionController < ApplicationController
	before_action :authenticate_teacher!
	def dashboard
		# session[:teacher_id] ||= current_user.id
	end
end
