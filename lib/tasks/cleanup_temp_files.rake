namespace :cleanup do
  desc "Limpiar archivos temporales de actas antiguos (más de 24 horas)"
  task temp_actas: :environment do
    temp_dir = Rails.root.join('tmp')
    cutoff_time = 24.hours.ago
    
    files_to_delete = Dir.glob(File.join(temp_dir, "actas_periodo_*.pdf")).select do |file|
      File.mtime(file) < cutoff_time
    end
    
    if files_to_delete.any?
      files_to_delete.each do |file|
        begin
          File.delete(file)
          puts "Eliminado: #{File.basename(file)}"
        rescue => e
          puts "Error eliminando #{File.basename(file)}: #{e.message}"
        end
      end
      puts "Se eliminaron #{files_to_delete.count} archivos temporales"
    else
      puts "No se encontraron archivos temporales para eliminar"
    end
  end
end 