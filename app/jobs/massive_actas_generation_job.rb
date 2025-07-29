class MassiveActasGenerationJob < ApplicationJob
  queue_as :default

  def perform(academic_process_id, user_id = nil)
    academic_process = AcademicProcess.find(academic_process_id)
    sections = academic_process.sections.qualified
    
    # Procesar en chunks para evitar problemas de memoria
    chunk_size = 10
    pdf_parts = []
    
    sections.each_slice(chunk_size).with_index do |section_chunk, chunk_index|
      Rails.logger.info "Procesando chunk #{chunk_index + 1} de #{(sections.count.to_f / chunk_size).ceil}"
      
      chunk_pdfs = process_section_chunk(section_chunk)
      pdf_parts.concat(chunk_pdfs)
      
      # Pequeña pausa para evitar sobrecarga
      sleep(0.1) if chunk_index > 0
    end
    
    # Combinar todos los PDFs
    final_pdf = CombinePDF.new
    pdf_parts.each do |pdf_data|
      begin
        final_pdf << CombinePDF.parse(pdf_data)
      rescue => e
        Rails.logger.error "Error combinando PDF: #{e.message}"
      end
    end
    
    # Guardar el PDF final
    filename = "actas_periodo_#{academic_process.name}_#{Time.current.strftime('%Y%m%d_%H%M%S')}.pdf"
    file_path = Rails.root.join('tmp', filename)
    
    File.open(file_path, 'wb') do |file|
      file.write(final_pdf.to_pdf)
    end
    
    # Notificar al usuario si se proporcionó
    if user_id
      user = User.find(user_id)
      UserMailer.actas_generation_complete(user, file_path, filename).deliver_now
    end
    
    Rails.logger.info "Generación de actas completada: #{filename}"
  end

  private

  def process_section_chunk(sections)
    threads = []
    results = []
    
    sections.each do |section|
      thread = Thread.new do
        begin
          # Crear un nuevo contexto de renderizado para cada thread
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
          
          {section_id: section.id, pdf_data: pdf_data, success: true}
        rescue => e
          Rails.logger.error "Error procesando sección #{section.id}: #{e.message}"
          {section_id: section.id, success: false, error: e.message}
        end
      end
      
      threads << thread
    end
    
    # Esperar a que terminen todos los threads del chunk
    threads.each(&:join)
    
    # Recolectar resultados exitosos
    threads.map(&:value).select { |result| result[:success] }.map { |result| result[:pdf_data] }
  end
end 