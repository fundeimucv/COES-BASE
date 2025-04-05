def print_error e
	p "     ERROR: <#{e}>     ".center 800, '!'
end


desc "Importar dependencias desde asignaturas"
task :import_dependencias => :environment do
	begin
		Subject.importar_dependencias
		p "     Dependencias importadas     ".center 800, '!'
	rescue Exception => e
		print_error e
	end
end



desc "Actualizar subjects' departaments"
task :update_subject_departaments => :environment do
	total = 0
	with_subject_errors = []
	with_dpto_not_found = []
	with_subject_not_found = []
	Subject.all.each_with_index do |subject, i|
		code = subject.code

		asignatura = Asignatura.where(id: code).first
		
		dsc = subject.name
		
		asignatura ||= Asignatura.where("lower(descripcion) ILIKE LOWER('%#{dsc}%')").first
		if asignatura
			departamento = asignatura.departamento
			school = departamento.escuela.find_school
			# departament = school.departaments.find(name: departamento.descripcion)
			departament = school.departaments.where(name: departamento.descripcion.upcase).first
			departament ||= school.departaments.where("lower(name) ILIKE ?", departamento.descripcion.downcase).first

			if departament
				if subject.update(departament_id: departament.id)
					total += 1
					print "√"
				else
					with_subject_errors << subject.id
					print "X"
				end
				
			else
				print "D"
				with_dpto_not_found << subject.id
			end
		else
			print "S"
			with_subject_not_found << subject.id
		end
	end

	p "Total Migradas: #{total}"
	p "Total Error al guardar #{with_subject_errors.count}: #{with_subject_errors}"
	p "Total dpto no encontrada #{with_dpto_not_found.count}: #{with_dpto_not_found}"
	p "Total subject no encontrada #{with_subject_not_found.count}: #{with_subject_not_found}"
rescue Exception => e
	print_error e
end


desc "Actualizar estados de permanencia"
task :update_permanece_status => :environment do
	School.pregrado.each do |escuela|
		escuela.grades.each do |grade|
			grade.enroll_academic_processes.joins(:period).order('periods.year': :asc).each do |eap|
				print eap.update(permanence_status: eap.get_regulation) ? '√' : "X(#{eap.id})"
			end

		end
	end
rescue Exception => e
	print_error e
end


desc "Migrar Departamentos"
task :migrate_departamento => :environment do
	begin
		Departamento.all.each do |dpto|
			dp = Departament.new
			dp.name = dpto.descripcion
			dp.school_id = School.find_by(code: dpto.escuela_id)&.id
			print (dp.save) ? '-' : 'x'
		end
	rescue StandardError => e
		print_error e
	end		

end

desc "Migrar Cátedras"
task :migrate_catedras => :environment do
	begin
		Catedra.all.each do |cat|
			area = Area.find_by(name: cat.descripcion)
			
			name = area ? "#{cat.descripcion} (#{cat.id})" : cat.descripcion
			
			area = Area.new
			area.name = name
			
			area.save!

			print (area.save) ? '-' : cat.id
		end
	rescue StandardError => e
		print_error e
	end
end

desc "Migrar CatedraDepartamento"
task :migrate_catdpto => :environment do
	begin
		Departamento.all.each do |dpto|
			dpt = Departament.find_by(name: dpto.descripcion)
			# p "Departament: #{dpt.name}"
			dpto.catedras.each do |cat|
				area = Area.find_by(name: cat.descripcion.strip.upcase) 
				# p "Catedra: #{cat.descripcion}"
				# p "Area: #{area.name}"
				dpt.areas << area
				print dpt.save ? '-' : "x<#{dpto.id} - #{cat.id}>"
			end
		end
	rescue StandardError => e
		print_error "#{e }"
	end
end

desc "Migrar Usuarios"
task :migrate_usuarios => :environment do
	begin
		p 'iniciando importación usuarios... '
		# Usuario.where('usuarios.ci NOT IN (?)', User.all.map(&:ci)).each do |us|
		Usuario.all.order(:created_at).offset(22400).each do |us|

			u = User.find_or_initialize_by(ci: us.ci)
			if (us.email&.match? URI::MailTo::EMAIL_REGEXP and us.email&.length > 6)
				u.email = us.email 
			else
				u.email = "actualizar-correo#{us.ci}@mailinator.com"
			end
			p us.ci
			u.first_name = us.nombres
			u.last_name = us.apellidos
			u.password = us.password
			u.location_number_phone = us.telefono_habitacion 
			u.number_phone = us.telefono_movil
			u.sex = us.sexo


			if adjunto = Adjunto.where(name: 'imagen_ci', record_type: 'Usuario', record_id: us.ci).first
				blob_id = adjunto.adjuntoblob_id
				blob = ActiveStorage::Blob.find blob_id
				u.ci_image.attach blob if blob
			end

			if adjunto = Adjunto.where(name: 'foto_perfil', record_type: 'Usuario', record_id: us.ci).first
				blob_id = adjunto.adjuntoblob_id
				blob = ActiveStorage::Blob.find blob_id
				u.profile_picture.attach blob if blob
			end

			if (u.save)
				print '-'
			else
				
				u.email = "actualizar-correo#{us.ci}@mailinator.com" if u.errors.attribute_names.include? :email
				u.password = u.ci if u.errors.attribute_names.include? :password
				
				print u.save ? '-√' : "< E:#{u.errors.full_messages.to_sentence}| CI: #{us.ci} >"
			end

    	end

	rescue StandardError => e
		print_error e
	end
	
end

desc "Migrar Planes"
task :migrate_planes => :environment do
	begin
		p 'Iniciando migración de Planes...'	

		Plan.all.each do |plan|

			school = School.where(code: plan.escuela_id).first

			sp = StudyPlan.new
			sp.school_id = school.id
			sp.code = plan.id
			sp.name = plan.descripcion
		
			if (school.code.eql? 'IDIO' or school.code.eql? 'EDUC')
				sp.modality =  'Anual'
				sp.levels = 5
			else
				sp.modality =  'Semestral'
				sp.levels = 10
			end
		
			p sp.save ? '-' : "#{sp.errors.full_messages.to_sentence}"
		
		end
		
	rescue StandardError => e
		p e
	end
end

desc "Migrar Estudiantes"
task :migrate_estudiantes => :environment do
	begin
		p 'iniciando... '
		Estudiante.all.includes(:usuario).order(:created_at).each do |es|
			us = es.usuario
			
			if u = User.where(ci: us.ci).first
				st = Student.find_or_initialize_by(user_id: u.id)
				if st.new_record?
					st.active = es.activo
					st.birth_date = us.fecha_nacimiento
					
					st.disability = es.discapacidad&.upcase
					st.grade_title = es.titulo_universitario
					st.grade_university = es.titulo_universidad
					st.graduate_year = es.titulo_anno
					st.marital_status = us.estado_civil
					st.nacionality = us.nacionalidad
					st.origin_city = us.ciudad_nacimiento
					st.origin_country = us.pais_nacimiento
					st.save ? (print '+') : (p "x#{st.errors.full_messages.to_sentence} |#{es.usuario_id}")
				else
					print '='
				end
			else
				p "Error: usuario con CI: #{us.ci} no encontrado"
			end

    	end

	rescue StandardError => e
		print_error e
	end
end

desc "Migrar Profesores"
task :migrate_profesores => :environment do
	begin
		p 'iniciando migración de profesores... '
		total_user_not_found = 0
		total_teacher_exist = 0
		total_dpto_not_found = 0
		Profesor.all.includes(:usuario, :departamento).each do |profe|
			us = profe.usuario
			dpto = profe.departamento
			# p "   Trabajando con: <#{us.descripcion}>...<#{dpto.descripcion_completa}>    "
			if u = User.where(ci: us.ci.gsub(/[^0-9]/, '')).first
				# p u.name
				pro = Teacher.find_or_initialize_by(user_id: u.id)
				if pro.new_record?
					if departament = Departament.where(name: dpto.descripcion).first
						pro.departament = departament
						pro.save ? (print '+') : (p "x#{pro.errors.full_messages.to_sentence} |#{profe.usuario_id}")

					else
						total_dpto_not_found += 1
						# p 'Departamento no encontrado'+ dpto.descripcion_completa
					end
				else
					total_teacher_exist += 1
					print '='
				end
			else
				total_user_not_found += 1
				p "Error: usuario con CI: #{us.ci} no encontrado"
			end

			
    	end
		
		p "      Total Esperado: #{Profesor.count}       ".center(400, '-')
		p "      Total Usuarios No Encontrados: #{total_user_not_found}       ".center(400, '-')
		p "      Total Profesores ya existentes: #{total_teacher_exist}       ".center(400, '-')
		p "      Total Dptos no encontrados: #{total_dpto_not_found}       ".center(400, '-')
	rescue StandardError => e
		print_error e
	end
end

desc "Migrar Periodos"
task :migrate_periodos => :environment do
	begin
		p 'iniciando migración de periodos... '
		
		total_periods_exist = 0
		total_new_records = 0
		total_errors = 0

		Periodo.all.order(:created_at).each do |periodo|
			
			año, tipo = periodo.id.split('-')
			if año and tipo
				orden = tipo[0..1]
				tipo = tipo.last

				# p "Año: #{año} | Orden: #{orden} | Tipo: #{tipo}"
				
				if period_type = PeriodType.where(code: orden).first

					period = Period.find_or_create_by(year: año.to_i, period_type_id: period_type.id)
					periodo.escuelaperiodos.each do |ep|
						school = School.find_by(code: ep.escuela_id)
						ap = AcademicProcess.find_or_initialize_by(period_id: period.id, school_id: school.id)
						ap.max_credits = ep.max_creditos
						ap.max_subjects = ep.max_asignaturas
						ap.modality = AcademicProcess.letter_to_modality tipo
						
						if ap.new_record?
							if ap.save 
								total_new_records += 1
								print '+'
							else
								total_errors += 1
								p "Error al intentar guardar el AcademicProcess: #{ap.errors.full_messages.to_sentence}"
							end
						else
							print '='
							total_periods_exist += 1
						end
					end
				else
					total_errors += 1
					p 'Tipo Período no encontrado: '+periodo.id
				end
			else
				total_errors += 1
				#p 'Periodo inválido: '+periodo.id
			end
			
    	end
		
		p "      Total Esperado: #{Periodo.count}       ".center(400, '-')
		p "      Agregados: #{total_new_records}       ".center(400, '-')
		p "      Existentes: #{total_periods_exist}       ".center(400, '-')
		p "      No guardados: #{total_errors}       ".center(400, '-')


	rescue StandardError => e
		print_error e
	end
end

desc "Migrar Grados"
task :migrate_grados => :environment do
	begin
		p 'iniciando migración de grados... '
		total_student_not_found = 0
		total_grade_exist = 0
		total_new_records = 0
		total_errors = 0
		# Grado.includes(:reportepago).where.not(reportepago_id: nil).order(:created_at).each do |grado|
		Grado.all.includes(:reportepago).order(:created_at).each do |grado|
			# Estudiante
			salida = grado.importar_grado
			print salida
			case salida				
			when 'x'
				print " grado:#{ grado.id}"
				total_errors += 1
				
			when '='
				total_grade_exist += 1
			when '+'
				total_new_records += 1				
			when 'Estudiante o Plan no encontrado'
				print " grado:#{ grado.id}"
				total_student_not_found += 1
			end

    	end
		
		p "      Total Esperado: #{Grade.count}       ".center(400, '-')
		p "      Total Estudiantes No Encontrados: #{total_student_not_found}       ".center(400, '-')
		p "      Total Nuevos registros agregados: #{total_new_records}       ".center(400, '-')
		p "      Total Grados Existentes: #{total_grade_exist}       ".center(400, '-')
		p "      Total no guarddos: #{total_errors}       ".center(400, '-')
	rescue StandardError => e
		print_error e
	end
end

desc "Migrar Grados"
task :migrate_historialplanes => :environment do
	begin
		p 'iniciando migración de historialplanes... '

		# Historialplan.all.includes(:grado).order(:created_at).each do |historial|
		Grado.includes(:historialplanes).order(:created_at).offset(5812).each do |grado|
			# Estudiante
			if grade = grado.find_grade
				grado.historialplanes.each do |historial|

					if historial.plan
						sp = StudyPlan.where(code: historial.plan_id).first
						print grade.update(study_plan_id: sp.id) ? '√' : " X <#{historial.id}>  "
					else
						print " X <#{historial.id}>  "
					end
				end
			end
    	end
	rescue StandardError => e
		print_error e
	end
end

desc "Migrar Asignaturas"
task :migrate_asignaturas => :environment do
	p 'iniciando migración de asignaturas... '
	
	Asignatura.order(:created_at).each do |asignatura|
		begin			
			print asignatura.import_subject
		rescue StandardError => e
			print_error "#{e} | #{asignatura.id}"
    	end
	end
end

desc "Migrar Programación"
task :migrate_programacion => :environment do

	p 'iniciando migración de programacion... '
	# total_not_found = 0
	total_exist = 0
	total_new_records = 0
	total_errors = 0

	# Grado.includes(:reportepago).where.not(reportepago_id: nil).order(:created_at).each do |grado|
	Programacion.order(:created_at).each_with_index do |prog, i|
		begin
			
			salida = prog.import_course
			print salida
			if salida.eql? '+'
				total_new_records += 1
			elsif salida.eql? '='
				total_exist += 1
			else
				p prog.descripcion
				total_errors += 1
				break
			end 
			
			
		rescue StandardError => e
			print_error "#{e} | #{prog.descripcion}"
			break
		end
	end

		
	p "      Total Esperado: #{Programacion.count}       ".center(400, '-')
	p "      Total Nuevos registros agregados: #{total_new_records}       ".center(400, '-')
	p "      Total Existentes: #{total_exist}       ".center(400, '-')
	p "      Total Errores: #{total_errors}       ".center(400, '-')
end

desc "Migracion de Registros Académicos"
task :migrate_inscripcionsecciones, [:offset] => [:environment] do |t, args|	
	Inscripcionseccion.total_import(args[:offset])
end

desc "Migracion de Direcciones"
task :migrate_direcciones => :environment do
	Direccion.migrate_addresses
end

desc "Migracion Reporte de Pago de Inscripciones"
task :migrate_all_reportepagos => :environment do
	total_exist = 0
	total_new_records = 0
	total_errors = 0
	inscripciones_con_reporte = Inscripcionescuelaperiodo.joins(:reportepago).order(:id)
	inscripciones_con_reporte.each do |ins|
		begin
			salida = ins.migrate_reportepago	
			print salida
			if salida.eql? '+'
				total_new_records += 1
			elsif salida.eql? '='
				total_exist += 1
			elsif salida.eql? '*'
				print "No enonctrado: #{ins.id}"
				total_errors += 1
				break
			else
				p "Error en #{ins.id}"
				total_errors += 1
				break
			end 				

		rescue Exception => e 
			p "ERROR: #{e}: (#{ins.id})"
			break
		end
		
	end
	p "      Total Esperado: #{inscripciones_con_reporte.count}       ".center(300, '-')
	p "      Total Nuevos registros agregados: #{total_new_records}       ".center(300, '-')
	p "      Total Existentes: #{total_exist}       ".center(300, '-')
	p "      Total Errores: #{total_errors}       ".center(300, '-')		

end


desc "Actualiza todas inscripciones segun el reglamento"
task :update_all_enrollment_status => :environment do
	begin
		p 'iniciando... '
		AcademicProcess.reorder(name: :asc).each do |ap|
			p "Periodo: #{ap.process_name}"
			ap.enroll_academic_processes.each do |eap| 
				if eap.finished?
					print eap.update(permanence_status: eap.get_regulation) ? '.' : 'x'

				else
					print "-#{eap.id}-"
				end
			end
			p "/"
    	end

	rescue StandardError => e
		p e
	end
	
end

desc "Actualiza los numeritos de las inscripciones"
task :update_enroll_academic_processes_numbers => :environment do
	begin
		p 'iniciando... '
		AcademicProcess.reorder(name: :asc).each do |ap|
			p "Periodo: #{ap.process_name}"
			ap.enroll_academic_processes.each do |eap| 


				print eap.update(efficiency: eap.calculate_efficiency, simple_average: eap.calculate_average, weighted_average: eap.calculate_weighted_average) ? '.' : "x#{eap.id}"
			end
			p "/"
		end

	rescue StandardError => e
		p e
	end
	
end

#   def update_all_efficiency

#     Grados.each do |gr| 
#       academic_records = gr.academic_records
#       cursados = academic_records.total_credits_coursed
#       aprobados = academic_records.total_credits_approved

#       eficiencia = (cursados and cursados > 0) ? (aprobados.to_f/cursados.to_f).round(4) : 0.0

#       aux = academic_records.coursed

#       promedio_simple = aux ? aux.round(4) : 0.0

#       aux = academic_records.weighted_average
#       ponderado = (cursados > 0) ? (aux.to_f/cursados.to_f).round(4) : 0.0
#     end

#   end

