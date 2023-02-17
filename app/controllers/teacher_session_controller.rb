class TeacherSessionController < ApplicationController
	before_action :authenticate_teacher!
	def dashboard
	end
end
