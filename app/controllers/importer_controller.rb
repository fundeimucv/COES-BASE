class ImporterController < ApplicationController
	def entities
		case params[:entity]
		when 'subjects'	
			require_fields = ['id', 'nombre']
		when 'students', 'teachers'
			require_fields = ['ci', 'email', 'nombres', 'apellidos'] 
		when 'sections'
			require_fields = ['numero', 'codigo', 'capacidad', 'profesor_ci'] 
		when 'academic_records'
			require_fields = ['ci', 'codigo', 'numero'] 
		end
	
		if require_fields
			result = ImportXslx.general_import params, require_fields
			if result[0].eql? 1 # Exito
				flash[:success] = result[1]
				if params[:entity]
					redirect_to "/admin/#{params[:entity].singularize}"
				else
					redirect_back fallback_location: root_path	
				end

			else
				flash[:danger] = result[1]
				redirect_back fallback_location: root_path	
			end
		else
			flash[:danger] = 'Tipo de entidad no encontrada. Por favor inténtelo nuevamente.'
			redirect_back fallback_location: root_path
		end


	end

end
