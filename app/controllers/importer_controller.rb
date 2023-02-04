class ImporterController < ApplicationController

	def students
		resultado = ImportCsv.import_students params[:datafile].tempfile, params[:study_plan_id], params[:admission_type_id], params[:registration_status]

		flash[:info] = resultado[0]
		errores = resultado[1]
		if errores.sum.count > 0
			flash[:danger] = "Inconvenientes en el archivo impiden su procesamiento. corríjalos e inténtelo nuevamente. "
			flash[:danger] += "Usuarios No Agregados (#{errores[0].count}): <b>#{errores[0].to_sentence.truncate(40)} | " if errores[0].count > 0
			flash[:danger] += "Estudiantes No Agregados (#{errores[1].count}): <b>#{errores[1].to_sentence.truncate(40)} | " if errores[1].count > 0
			flash[:danger] += "Carreras No Agregadas (#{errores[2].count}): <b>#{errores[2].to_sentence.truncate(40)} | " if errores[2].count > 0
			flash[:danger] += "Estudiates Con plan_id Errado en total (#{errores[3].count}): <b>#{errores[3].to_sentence.truncate(40)} | " if errores[3].count > 0
			flash[:danger] += "Estudiates Con tipo_ingreso Errado (#{errores[4].count}): <b>#{errores[4].to_sentence.truncate(40)} | " if errores[4].count > 0
			flash[:danger] += "Estudiates Con iniciado_periodo_id Errado (#{errores[5].count}): <b>#{errores[5].to_sentence.truncate(40)} | " if errores[5].count > 0
			flash[:danger] += "Estudiates Con region Errado (#{errores[6].count}): <b>#{errores[6].to_sentence.truncate(40)} | " if errores[6].count > 0
			flash[:danger] += "Error General (#{errores[7].count}): <b>#{errores[7].to_sentence.truncate(200)} | " if errores[7].count > 0
			flash[:danger] += "Las siguentes cabeceras no se encuentran en el archivo o están mal escritas: #{errores[8].to_sentence}. Por favor vuelva a escribirlas en minúsculas, sin acentos ni espacios." if errores[8].count > 0
			redirect_back fallback_location: root_path
		else
			redirect_to '/admin/student'
		end
	end

	def teachers
		resultado = ImportCsv.import_teachers params[:datafile].tempfile, params[:area_id]
		if resultado[0].eql? 1
			flash[:info] = resultado[1]
			redirect_to '/admin/teacher'
		else
			flash[:danger] = resultado[1]
			redirect_back fallback_location: root_path	
		end
	end

	def subjects
		resultado = ImportCsv.import_subjects params[:datafile].tempfile, params[:area_id], params[:qualification_type], params[:modality]
		if resultado[0].eql? 1
			flash[:success] = resultado[1]
			redirect_to '/admin/subject'
		else
			flash[:danger] = resultado[1]
			redirect_back fallback_location: root_path	
		end
	end

	def academic_records
		params[:period_id] = nil if params[:period_in_file]

		resultado = ImportCsv.import_academic_records params[:datafile].tempfile, params[:study_plan_id], params[:period_id]

		if resultado[0].eql? 1
			flash[:info] = resultado[1]
			redirect_to '/admin/academic_record'
		else
			flash[:danger] = resultado[1]
			redirect_back fallback_location: root_path
		end
	end

end
