class StudentSessionController < ApplicationController
	before_action :authenticate_student!
	before_action :set_session_id_if_multirols, only: [:dashboard]

	def dashboard
	end
end
