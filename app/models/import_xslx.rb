class ImportXslx

	def self.general_import fields, headers_layout
		require 'simple_xlsx_reader'

		errores_cabeceras = []

		begin
			doc = SimpleXlsxReader.open(fields[:datafile].tempfile)
			hoja = doc.sheets.first
			rows = hoja.rows			
			headers = rows.shift 
			temp = headers.first
			headers = rows.shift unless (temp.include? 'id' or temp.include? 'ci') # funciona si el nombre del archivo no tiene espacios

			# rows = hoja.data#.rows#.group_by{|row| row[0]}.values

			headers.compact!
			if headers = headers.map(&:downcase)		 
				headers_layout.each do |head| 
					errores_cabeceras << "Falta la cabecera '#{head}' en el archivo o está mal escrita" unless headers.include? head	
				end
			else
				errores_cabeceras << "La cabecera del archivo no se encuentra. Por favor genere nuevamente el archivo." 
			end

		rescue Exception => e
			errores_cabeceras << "Error al intentar abrir el archivo: #{e}"
		end


		if errores_cabeceras.count > 0
			errores_cabeceras << headers
			return [0, "Error en las cabaceras del archivo: #{errores_cabeceras.to_sentence}"]
		else		
			errors = []
			error_type = 1
			total_newed = 0
			total_updated = 0
			resumen = ""
			row_record = ''
			row_index = 0

			begin
				# rows.shift

				rows.each_with_index do |row, i|
					row_record = row
					row_index = i
					sum_newed, sum_updated, sum_errors = fields[:entity].singularize.camelize.constantize.import row, fields
					errors << sum_errors unless sum_errors.blank?
					total_newed += sum_newed
					total_updated += sum_updated
				end

			rescue Exception => e
				return [0, "Error General : #{e} al rededor de la línea #{row_index}: #{row_record}"]
			end

			resumen += "Nuevos Registros: #{total_newed} | "
			resumen += "Actualizados: #{total_updated} | "

			if errors.any? and (errors.include? '[nil, nil, nil, nil, nil, nil]')
				resumen += "Total Errores: #{errors.count} | " 
				resumen += "Tipo de Error: #{errors.uniq.to_sentence}"
				error_type = 0 
			end

			return [error_type, "Proceso de importación completado. #{resumen}"]
		end

	end

end