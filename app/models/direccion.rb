class Direccion < ApplicationRecord
	self.table_name = 'direcciones'
	belongs_to :estudiante, foreign_key: :estudiante_id 

	# VALIDACIONES:
	validates :estudiante_id, presence: true, uniqueness: true
	validates :estado, presence: true
	validates :municipio, presence: true
	validates :ciudad, presence: true
	validates :sector, presence: true
	validates :calle, presence: true
	validates :tipo_vivienda, presence: true
	validates :nombre_vivienda, presence: true

	def descripcion_completa
		"#{estado} - #{municipio} - #{ciudad} - #{sector} - #{calle}, #{tipo_vivienda}: #{nombre_vivienda}"
	end

	def self.migrate_addresses
		total_errors = total_exist = total_new = 0
		Direccion.all.each do |dir|
			salida = dir.import_address
			print salida
			case salida
			when '='
				total_exist += 1
			when '+'
				total_new += 1
			else
				total_errors += 1
				p "En la dirección: #{dir.id}"
				break
			end
		end

		p "      Total Esperado: #{Direccion.count}       ".center(350, '-')
		p "      Total Nuevos registros agregados: #{total_new}       ".center(350, '-')
		p "      Total Existentes: #{total_exist}       ".center(350, '-')
		p "      Total Errores: #{total_errors}       ".center(350, '-')		
	end

	def import_address
		begin
			student = estudiante.find_by_student
			
			if address = student.address
				'='
			else
				address = Address.create(student_id: student.id, state: self.estado, municipality: self.municipio, city: ciudad, sector: self.sector, street: calle, house_type: self.tipo_vivienda&.downcase.to_sym, house_name: self.nombre_vivienda)
				if address.errors.any?
					"X#{address.errors.full_messaage.to_sentence}"
				else
					'+'
				end
			end
		rescue Exception => e
			"Excepcional: #{e}"
		end
	end


	def self.getIndexEstado estadoName
		estados = venezuela.map{|a| a["estado"]}
		estados.index(estadoName)
	end

	def self.getIndexMunicipio estadoName, municipioName
		indiceEstado = getIndexEstado estadoName
		venezuela[indiceEstado]["municipios"].map{|a| a["municipio"]}.index(municipioName)
	end

	def self.estados
		venezuela.map{|a| a["estado"]}
	end

	def self.municipios estadoName
		Direccion.venezuela[getIndexEstado(estadoName)]['municipios'].map{|a| a["municipio"]}.sort
	end

	def self.parroquias estadoName, municipioName
		indiceEstado = getIndexEstado(estadoName)
		indiceMunicipio = getIndexMunicipio(estadoName, municipioName)
      	venezuela[indiceEstado]["municipios"][indiceMunicipio]['parroquias'].map.sort
	end

    def self.venezuela
      require 'json'

      file = File.read("#{Rails.root}/public/venezuela.json")

      JSON.parse(file)
    end

end