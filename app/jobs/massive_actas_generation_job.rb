class MassiveActasGenerationJob < ApplicationJob
  queue_as :default

  def perform(academic_process_id, user_id = nil)

    p "     Iniciando proceso de actas masivas    ".center(1000, "#")

    academic_process = AcademicProcess.find(academic_process_id)
    sections = academic_process.sections.qualified
    
    # Procesar todas las secciones secuencialmente

    combined_pdf = CombinePDF.new
    
    sections.each_with_index do |section, index|

      p "     Procesando Acta sección #{section.name}    ".center(1000, "#")

      Rails.logger.info "Procesando sección #{index + 1} de #{sections.count}: #{section.id}"
      
      begin
        # Crear un nuevo contexto de renderizado para cada sección
        renderer = ApplicationController.renderer.new(
          http_host: Rails.application.config.action_mailer.default_url_options[:host],
          https: Rails.application.config.force_ssl
        )
          
        footer_html = renderer.render(
          template: "/sections/signatures", 
          locals: {teacher: section.teacher&.user&.acte_name}
        )
          
        header_html = renderer.render(
          template: "/sections/acta_header", 
          locals: {school: section.school, section: section}
        )
              
        pdf_data = renderer.render(
          template: "sections/acta",
          layout: false,
          page_size: 'letter', 
          margin: {top: 72, bottom: 68},
          locals: {section: section}, 
          formats: [:html],
          footer: {content: footer_html},
          header: {content: header_html}
        )
        
        # Verificar que el PDF se generó correctamente antes de combinarlo
        if pdf_data && pdf_data.bytesize > 0
          combined_pdf << CombinePDF.parse(pdf_data)
          Rails.logger.info "Sección #{section.id} procesada y combinada exitosamente - Tamaño: #{pdf_data.bytesize} bytes"
        else
          Rails.logger.error "Sección #{section.id} generó un PDF vacío o inválido"
        end

      rescue => e
        Rails.logger.error "Error procesando sección #{section.id}: #{e.message}"
      end
    end
    

    
    # Guardar el PDF final
    filename = "actas_periodo_#{academic_process.name}_#{Time.current.strftime('%Y%m%d_%H%M%S')}.pdf"
    file_path = Rails.root.join('tmp', filename)

    Rails.logger.info "Escribiendo Archivo"
    p "     Escribiendo Archivo    ".center(1000, "#")
    
    File.open(file_path, 'wb') do |file|
      file.write(combined_pdf.to_pdf)
    end
    
    # Notificar al usuario si se proporcionó
    if user_id
      user = User.find(user_id)
      p "Envinado Correo"
      UserMailer.actas_generation_complete(user, file_path, filename).deliver_now
    end
    
    p "Generación de actas completada: #{filename}"
    Rails.logger.info "Generación de actas completada: #{filename}"
  end
end 