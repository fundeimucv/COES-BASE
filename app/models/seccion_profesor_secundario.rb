# == Schema Information
#
# Table name: seccion_profesores_secundarios
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  profesor_id :string(255)
#  seccion_id  :bigint
#
class SeccionProfesorSecundario < ApplicationRecord
	self.table_name = 'seccion_profesores_secundarios'

	belongs_to :seccion
	belongs_to :profesor, primary_key: :usuario_id

	validates_uniqueness_of :profesor_id, scope: [:seccion_id], message: 'Profesor secundario ya existe para esta sección', field_name: false

	validates :seccion_id,  presence: true
	validates :profesor_id,  presence: true

	def general_desc
		"#{profesor_id} - #{seccion_id}"
	end

	def find_section_teacher
		section = seccion&.find_section
		teacher = profesor&.find_teacher
		SectionTeacher.where(teacher_id: teacher&.id, section_id: section&.id).first
	end

	def import_section_teacher
		if find_section_teacher
			'='
		else
			section = seccion&.find_section
			teacher = profesor&.find_teacher
			if (teacher and section)
				aux = SectionTeacher.create(teacher_id: teacher&.id, section_id: section&.id) 
				if aux
					'+' 
				else
					aux.errors.full_messages.to_sentence
				end
			else
				'Teacher or Section not found'
			end
		end
	end

	def	self.import_all_section_teachers
		p 'iniciando migración de registros académicos... '
		total_exist = 0
		total_new_records = 0
		total_errors = 0
		with_errors = []
	  
		total_mgs = ""
		SeccionProfesorSecundario.all.order(:created_at).each_with_index do |sps, i|
			begin
				salida = sps.import_section_teacher
				if salida.eql? '+'
					total_new_records += 1
				elsif salida.eql? '='
					total_exist += 1
				else
					p salida
					p sps.general_desc
					total_errors += 1
					with_errors << sps.id
				end
			rescue Exception => e
				msg = "#{e} | (#{sps.id}) #{sps.general_desc}"
				p msg 
				break
			end
	
		end
		total_mgs += "      Total Esperado: #{SeccionProfesorSecundario.count}       ".center(400, '-')
		total_mgs += "      Total Nuevos registros agregados: #{total_new_records}       ".center(400, '-')
		total_mgs += "      Total Existentes: #{total_exist}       ".center(400, '-')
		total_mgs += "      Total Errores: #{total_errors}       ".center(400, '-')
		total_mgs += "      Identificadores de SPS con errores: #{with_errors}    "
		
	end

end
