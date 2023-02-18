class StudentSessionController < ApplicationController
	def dashboard
		# session[:student_id] ||= current_user.id
		@title = 'Bienvenido a tu sesión de COESFAU'
	end
end
