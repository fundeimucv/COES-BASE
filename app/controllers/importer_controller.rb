class ImporterController < ApplicationController

	def students

		resultado = ImportCsv.import_student params[:datafile].tempfile, params[:school_id], params[:study_plan_id], params[:admission_type_id], params[:registration_status], current_user.id,request.remote_ip, params[:enviar_correo]

		flash[:info] = resultado[0]
		errores = resultado[1]
		if errores.count > 0
			flash[:danger] = "<h6>Algunos inconvenientes en el archivo. Por favor corrija los registros y cargue nuevamente el archivo</h6></br>"
			flash[:danger] += "Usuarios No Agregados (#{errores[0].count}): <b>#{errores[0].to_sentence.truncate(40)}</b><hr></hr>" if errores[0].count > 0
			flash[:danger] += "Estudiantes No Agregados (#{errores[1].count}): <b>#{errores[1].to_sentence.truncate(40)}</b><hr></hr>" if errores[1].count > 0
			flash[:danger] += "Carreras No Agregadas (#{errores[2].count}): <b>#{errores[2].to_sentence.truncate(40)}</b><hr></hr>" if errores[2].count > 0
			flash[:danger] += "Estudiates Con plan_id Errado en total (#{errores[3].count}): <b>#{errores[3].to_sentence.truncate(40)}</b><hr></hr>" if errores[3].count > 0
			flash[:danger] += "Estudiates Con tipo_ingreso Errado (#{errores[4].count}): <b>#{errores[4].to_sentence.truncate(40)}</b><hr></hr>" if errores[4].count > 0
			flash[:danger] += "Estudiates Con iniciado_periodo_id Errado (#{errores[5].count}): <b>#{errores[5].to_sentence.truncate(40)}</b><hr></hr>" if errores[5].count > 0
			flash[:danger] += "Estudiates Con region Errado (#{errores[6].count}): <b>#{errores[6].to_sentence.truncate(40)}</b><hr></hr>" if errores[6].count > 0
			flash[:danger] += "Error General (#{errores[7].count}): <b>#{errores[7].to_sentence.truncate(200)}</b><hr></hr>" if errores[7].count > 0
			flash[:danger] += "Error en las cabeceras: Las siguentes cabeceras no se encuentran en el archivo o están mal escritas: <b>#{errores[8].to_sentence} </b>. Por favor vuelva a escribirlas tomando en cuenta que deben estár en minúsculas y elimine espacios agregados al principio o al final de la palabra. <hr></hr>" if errores[8].count > 0
		end


		redirect_back fallback_location: root_path

		
	end
end
