class PdfDocs
  include ActionView::Helpers::NumberHelper
  include Prawn::View

  def self.career_finished_certificate career, verified=false
    # color_base = '001549'
    color_base = 'c88513'
    pdf = Prawn::Document.new(top_margin: 20, bottom_margin: 10, page_layout: :landscape, background: "app/assets/images/finished_certificate4.png")

    # Rails.root.join("app/assets/fonts/diploma.ttf")
    pdf.font_families.update( "DiplomaFamily" => {:normal => "app/assets/fonts/diploma.ttf"})

    if career.user.profile_image and career.user.profile_image.attached?
      require 'open-uri'
      pdf.image open(career.user.profile_image.service_url), at: [550, 500], height: 100
    end


    pdf.image "app/assets/images/banner_logos.png", width: pdf.bounds.width

    pdf.move_down 10
    pdf.text "UNIVERSIDAD CENTRAL DE VENEZUELA", align: :center
    pdf.move_down 3
    pdf.text "Escuela de Idiomas Modernos", align: :center
    pdf.move_down 3
    pdf.text "FUNDEIM", align: :center


    # pdf.image carrer.studiant.user.profile_image.service_url, at: [450, 720], height: 80

    # require 'open-uri'
    # pdf.image open(carrer.studiant.user.profile_image.service_url), at: [450, 720], height: 80



    pdf.image "app/assets/images/detail_down_title.png", position: :center, height: 30

    pdf.move_down 10
    pdf.text "Otorga el presente certificado a", align: :center, size: 12
    pdf.move_down 10

    size = (career.user.full_name_invert.size > 30) ? 35 : 45

    pdf.font("DiplomaFamily") do
      pdf.text career.user.full_name_invert, align: :center, color: color_base, size: size
    end
    pdf.move_down 5
    pdf.text "CI: #{career.student.ci}", align: :center, color: color_base, size: 20
    pdf.move_down 10
    pdf.text "por haber aprobado el curso de", align: :center, size: 12
    pdf.move_down 10
    pdf.text  "<b>#{career.language_category.name.upcase} COMO LENGUA EXTRANJERA</b>", align: :center, size: 20, inline_format: true
    pdf.move_down 10

    pdf.text "#{career.total_hours_career} horas académicas", align: :center, size: 12
    pdf.move_down 10
    pdf.text "Caracas, #{I18n.l(Time.now, format: '%d de %B de %Y')}", align: :center, size: 12

    pdf.move_down 10

    unless verified
      link = "https://aceim.fundeim.com/careers/#{career.id}/career_finished_certificate_verify"
    
      pdf.text "<a href='#{link}' style='margin-right:100px' target='_blank' rel='noopener noreferrer' >clic para verificar</a>", align: :center, size: 8, inline_format: true, color: color_base
    else
      pdf.move_down 5

    end

    pdf.move_down 40

    dir_value = GeneralSetup.director_value
    aca_dir_value = GeneralSetup.academic_director_value
    data = [["<b>#{dir_value}</b>", "<b>#{aca_dir_value}</b>"]] 

    # align: :center, size: 12, inline_format: true, background_color: 'EEEEEE'
    data << ["Director", "Coordinador"] # align: :center, size: 12, inline_format: true

    pdf.table data do |t|
      t.position = :center
      t.width = 500
      t.header = false
      t.cell_style = {inline_format: true, size: 12, border_color: 'f8f8f8', background_color: "f8f8f8", align: :center}
      t.column(0).style(:padding => [5, 60, 5, 0])
      t.column(1).style(:padding => [5, 0, 5, 60])
    end

    unless verified
      require 'rqrcode'

      qrcode = RQRCode::QRCode.new(link)

      png = qrcode.as_png(
        bit_depth: 1,
        border_modules: 4,
        color_mode: ChunkyPNG::COLOR_GRAYSCALE,
        color: 'black',
        file: "tmp/barcode.png",
        fill: 'white',
        module_px_size: 6,
        resize_exactly_to: false,
        resize_gte_to: false,
        size: 150
      )
      pdf.image "#{Rails.root.to_s}/tmp/barcode.png", width: 120, at: [300, 150]
    else
      pdf.image "app/assets/images/school_stamp.png", width: 120, at: [300, 150]
    end

    # pdf.text "#{pdf.bounds.width}" # 720


    if verified
      pdf.image "app/assets/images/signature_director.png", width: 150, at: [130, 170]
      pdf.image "app/assets/images/signature_aca_dir.png", width: 150, at: [445, 170]
      pdf.move_down 30
    end




    pdf.move_down 50

    pdf.text "<a href='https://www.freepik.es/vectores/certificado' style='margin-right:100px' target='_blank'>Vector de Certificado creado por freepik</a>", align: :right, size: 8, inline_format: true, color: 'EEEEEE'

    return pdf

  end



  def self.bill_payment payment_detail
    pdf = Prawn::Document.new(top_margin: 50)

    pdf.image "app/assets/images/logo_ucv.png", height: 60, valign: :top, at: [10,710]
    pdf.text "<b>FACTURA PROFORMA</b>", align: :right, size: 15,inline_format: true
    pdf.move_down 20
    pdf.text "<b>#{sprintf('%05i', payment_detail.id)}</b>", align: :right, size: 14, inline_format: true
    pdf.move_down 20
    data = [["<b>#{BankAccount.owns.first.holder}<b>", "<b>Fecha: </b> #{payment_detail.created_at.strftime('%d/%m/%Y')}"]]

    data << ["<b>#{GeneralSetup.fundeim_location_value}<b>", "<b>Cliente: </b> #{payment_detail.client_description}"]
    data << ["<b>#{GeneralSetup.fundeim_phone_value}<b>", ]
    data << ["<b>#{GeneralSetup.fundeim_email_value}<b>", ]

    pdf.table data do |t|
      t.width = 540
      t.header = false
      t.cell_style = {inline_format: true, size: 12, padding: 3, border_color: 'FFFFFF'}
      # t.column(2).style(:align => :justify)
      t.column(0).style(align: :left)
      t.column(1).style(align: :right)
      t.row(1).style(size: 10)
      t.row(2).style(size: 10)
      t.row(3).style(size: 10)
      t.column(1).width = 270
      # t.column(1).style(:font_style => :bold)
    end

    pdf.move_down 80

    data = [["<b>Descripción<b>", "<b>Importe </b>"]]

    total_bs = ActionController::Base.helpers.number_to_currency(payment_detail.mount, unit: 'Bs.', separator: ",", delimiter: ".")

    # total_bsD = ActionController::Base.helpers.number_to_currency(payment_detail.mount.to_f/1000000.0, unit: 'Bs.D', separator: ",", delimiter: ".")

    data << [payment_detail.course_description.html_safe, "#{total_bs}"]
    data << ['IVA (16%)', '0 Bs.']
    data << ['<b>TOTAL PROFORMA (Bs.S):</b>', "<b>#{total_bs}</b>"]

    pdf.table data do |t|
      t.position = :center
      t.width = 450
      t.header = true
      t.row_colors = ["F8F8FE","F8F8FE"]
      t.cell_style = {inline_format: true, size: 12, padding: 10, border_color: 'FFFFFF', valign: :center}
      # t.column(2).style(:align => :justify)
      t.row(0).style(background_color: "DCDCDC")
      t.column(0).style(align: :left)
      t.column(1).row(0).style(align: :center)
      t.column(1).row(1).style(align: :right)
      t.column(1).width = 150
      t.row(2).style(align: :right)
      t.row(3).style(size: 14, align: :right, border_color: 'FFFFFF', background_color: "FFFFFF")

      # t.column_widths = {0 => 5, 2 => 120}
      # t.column(1).style(:font_style => :bold)
    end


    return pdf

  end

  def self.normative pdf
    
    pdf.move_down 10
    pdf.text "<b>IMPORTANTE:</b>" , align: :center, size: 12, inline_format: true
    pdf.move_down 10
    pdf.text "<b>Usted aceptó la siguiente normativa:</b>" , align: :center, size: 12, inline_format: true
    pdf.move_down 10
    pdf.text "1.  Es obligatorio leer con detenimiento toda la información suministrada en el mensaje de inicio y en el módulo introductorio de su aula en CANVAS. Si tiene alguna duda sobre ACEIM o CANVAS,  o presenta algún inconveniente con el programa en general, debe contactar de inmediato a su instructor o a FUNDEIM por el correo fundeimucv@gmail.com." , align: :justify, size: 11
    pdf.move_down 10
    pdf.text "2.  Su participación en las actividades del foro es obligatoria y será tomada como asistencia a clase. La ausencia en el foro por 3 semanas, no necesariamente de manera consecutiva, tendrá como consecuencia la pérdida del curso por inasistencia." , align: :justify, size: 11
    pdf.move_down 10
    pdf.text "3.  La calificación mínima aprobatoria es de 15 puntos. La evaluación será continua y dinámica. Encontrará mayor información en el cronograma del curso incluido en el módulo introductorio del nivel." , align: :justify, size: 11
    pdf.move_down 10
    pdf.text "4.  El programa ONLINE consta de solo actividades asíncronas, es decir, no serán clases en vivo,  para que usted pueda organizarse y buscar el tiempo y la conexión para seguir formándose a su ritmo y en el horario de su preferencia; sin embargo, debe completar dos clases por semana, además de realizar las tareas asignadas y los exámenes semanales programados." , align: :justify, size: 11
  end

  def self.certificate academic_record
    pdf = Prawn::Document.new(top_margin: 20)

    content_academic pdf, academic_record

    put_profile_image academic_record.user, pdf
    
    pdf.move_down 10
    normative pdf

    pdf.bounding_box [pdf.bounds.left, pdf.bounds.bottom + 25], :width  => pdf.bounds.width do
        pdf.font "Helvetica"
        pdf.stroke_horizontal_rule
        pdf.move_down(5)
        pdf.text 'Cuidad Universitaria de Caracas - FUNDEIM - UCV #VenciendoLaSombra', size: 11, align: :center
    end

    return pdf

  end

  def self.get_work_proof instructor
    pdf = Prawn::Document.new(top_margin: 20, left_margin: 60, right_margin: 60, bottom_margin: 10)

    banner_width_logo pdf, nil, 10
    pdf.move_down 20

    put_profile_image instructor.user, pdf

    pdf.text '<b>CONSTANCIA</b>', size: 16, align: :center, inline_format: true

    pdf.move_down 20

    cursos = instructor.sections.map { |sec| sec.desc_work_proof }.to_sentence(last_word_connector: ' y ')

    pdf.text "Quien suscribe, en mi condición de Director de la Escuela de Idiomas Modernos de la Facultad de Humanidades y Educación de la Universidad Central de Venezuela y Presidente de la Fundación de la Escuela de Idiomas Modernos (FUNDEIM), de conformidad con la atribución establecida en el literal d) de la Cláusula Decima Primera de los Estatutos de la referida fundación; hago constar por medio de la presente que el(la) ciudadano(a) <b>#{instructor.user.full_name.upcase}</b>, titular de la cédula de identidad N° #{instructor.ci} ha participado en calidad de Pasante bajo la modalidad de INSTRUCTOR de los siguientes periodos del <b>PROGRAMA DE CURSOS DE IDIOMAS DE FUNDEIM</b>: #{cursos}, con una duración de seis (6) semanas cada uno.", size: 11, align: :justify, inline_format: true 
    
    pdf.move_down 20

    pdf.text "Esta constancia se expide a solicitud de la parte interesada. En Caracas, #{I18n.l(Time.now, format: 'a los %d días del mes de %B de %Y')}.", size: 11, align: :justify, inline_format: true

    pdf.move_down 40

    pdf.text "<b>#{GeneralSetup.director_value}</b>", align: :center, size: 11, inline_format: true
    pdf.text "<b>C.I. N° #{GeneralSetup.director_ci_value}</b>", align: :center, size: 11, inline_format: true
    pdf.text "Director de Escuela de Idiomas Modernos de la Facultad de Humanidades", align: :center, size: 9
    pdf.text "y Educación de la Universidad Central de Venezuela y Presidente de Fundeim", align: :center, size: 9
    pdf.move_down 20

    pdf.text "<b>IMPORTANTE:</b> PARA VALIDAR LA AUTENTICIDAD DEL PRESENTE DOCUMENTO ESCANEE EL SIGUIENTE CÓDIGO QR CON SU DISPOSITIVO APROPIADO PARA ELLO:" , align: :justify, size: 11, inline_format: true

    require 'rqrcode'

    # include Rails.application.routes.url_helpers

    # link = URI.join(root_url, "instructors/#{instructor.id}/work_proof_verify").to_s
    link = "/instructors/#{instructor.id}/work_proof_verify"
    qrcode = RQRCode::QRCode.new(link)

    png = qrcode.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: 'black',
      file: "tmp/barcode.png",
      fill: 'white',
      module_px_size: 6,
      resize_exactly_to: false,
      resize_gte_to: false,
      size: 150
    )

    pdf.image "#{Rails.root.to_s}/tmp/barcode.png", image_width: 50, image_height: 50, position: :center
    pdf.text "o haga clíc <a href='#{link}' target='_blank' rel='noopener noreferrer' >aquí</a>", align: :center, size: 8, inline_format: true



    pdf.bounding_box [pdf.bounds.left, pdf.bounds.bottom + 35], :width  => pdf.bounds.width do
        pdf.font "Helvetica"
        pdf.stroke_horizontal_rule
        pdf.move_down(5)
        pdf.text 'Cuidad Universitaria de Caracas - FUNDEIM - UCV #VenciendoLaSombra', size: 8, align: :center
        pdf.text GeneralSetup.fundeim_location_value, size: 8, align: :center
        pdf.text GeneralSetup.fundeim_phone_value, size: 8, align: :center

    end
    return pdf

  end


  def self.constance career
    pdf = Prawn::Document.new(top_margin: 20, left_margin: 60, right_margin: 60, bottom_margin: 10)

    banner_width_logo pdf, nil, 10
    
    put_profile_image career.user, pdf

    pdf.move_down 22

    pdf.text '<b>CONSTANCIA</b>', size: 16, align: :center, inline_format: true

    pdf.move_down 10

    pdf.text "Quien suscribe, #{GeneralSetup.director_value}, Director de la Escuela de Idiomas Modernos de la Facultad de Humanidades y Educación de la Universidad Central de Venezuela, hace constar por medio de la presente que el ciudadano:", size: 11, align: :justify
    pdf.move_down 10

    pdf.text "<b>#{career.student.constance_name}</b>", size: 13, align: :center, inline_format: true 
    pdf.move_down 10

    pdf.text "Aprobó del curso <b>#{career.language_category.name}</b> los niveles que se indican a continuación:", size: 11, align: :justify, inline_format: true

    approved_records pdf, career.academic_records.approved
    
    pdf.text "Cada nivel tiene una duración de #{career.academic_records.last.period.academic_hours} horas académicas (6 semanas aproximadamente).", size: 11, align: :justify, inline_format: true

    pdf.move_down 10

    pdf.text "Esta constancia se expide a solicitud de la parte interesada. En Caracas, #{I18n.l(Time.now, format: 'a los %d días del mes de %B de %Y')}.", size: 11, align: :justify, inline_format: true



    pdf.move_down 40

    pdf.text GeneralSetup.director_value, align: :center, size: 11
    pdf.move_down 20

    pdf.text "<b>IMPORTANTE:</b> PARA VALIDAR LA AUTENTICIDAD DEL PRESENTE DOCUMENTO ESCANEE EL SIGUIENTE CÓDIGO QR CON SU SMARTPHONE:" , align: :justify, size: 11, inline_format: true

    require 'rqrcode'

    link = "https://aceim.fundeim.com/careers/#{career.id}/constance_verify"
    qrcode = RQRCode::QRCode.new(link)

    png = qrcode.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: 'black',
      file: "tmp/barcode.png",
      fill: 'white',
      module_px_size: 6,
      resize_exactly_to: false,
      resize_gte_to: false,
      size: 150
    )

    pdf.image "#{Rails.root.to_s}/tmp/barcode.png", image_width: 50, image_height: 50, position: :center
    pdf.text "o haga clíc <a href='#{link}' target='_blank' rel='noopener noreferrer'>aquí</a>", align: :center, size: 8, inline_format: true



    pdf.bounding_box [pdf.bounds.left, pdf.bounds.bottom + 35], :width  => pdf.bounds.width do
        pdf.font "Helvetica"
        pdf.stroke_horizontal_rule
        pdf.move_down(5)
        pdf.text 'Cuidad Universitaria de Caracas - FUNDEIM - UCV #VenciendoLaSombra', size: 8, align: :center
        pdf.text GeneralSetup.fundeim_location_value, size: 8, align: :center
        pdf.text GeneralSetup.fundeim_phone_value, size: 8, align: :center

    end
    return pdf

  end


  def self.approved_records pdf, academic_records
    pdf.move_down 25
    data = [['Nivel', 'Período', 'Calificación']]
    academic_records.each do |ar|
      data << ["<b>#{ar.level.name}<b>", "<b>#{ar.period.name}</b>", "<b>#{ar.final_qualification}</b>"]
    end

    # pdf.table([[t,v]], width: 560, cell_style: {border_width: 0})

    pdf.table data do |t|
      t.width = 500
      t.position = :center
      t.header = true
      t.cell_style = {inline_format: true, size: 10, padding: 3, border_color: 'FFFFFF', align: :center}

    end
    pdf.move_down 25
  end



  def self.content_academic pdf, academic_record
    student = academic_record.student
    user = student.user
    payment = academic_record.payment_detail
    
    banner_width_logo pdf, "CONSTANCIA DE INSCRIPCIÓN"


    pdf.text "<b>Datos de la Inscripción:</b>", size: 11, inline_format: true

    # pdf.text "El departamento de Control de Estudios de la Facultad de HUMANIDADES Y EDUCACIÓN, por medio de la presente hace constar que #{usuario.la_el} BR. <b>#{estudiante.usuario.apellido_nombre}</b>, titular de la Cédula de Identidad <b>#{estudiante.id}</b> está <b>preinscrit#{usuario.genero}</b> en la Escuela de <b>#{escuela.descripcion.upcase}</b> de la Universidad Central de Venezuela.", size: 10, inline_format: true, align: :justify
    # Opcion 1:
    # pdf.image "app/assets/images/foto-perfil.png", at: [430, 395], height: 100

    pdf.move_down 20

    data = [['<b>Fecha Registro: <b>', academic_record.created_at.strftime('%d/%m/%Y')]]
    data << ['<b>Período: <b>', academic_record.period.name]
    data << ['<b>Estudiante: <b>', user.description]
    data << ['<b>Curso: <b>', academic_record.course_period.course.name]
    data << ['<b>Modalidad: <b>', academic_record.period.modality.capitalize]
    data << ['<b>Convenio: <b>', academic_record.agreement.name]

    # data << ['<b>Monto: <b>', "#{number_to_currency(payment.mount, unit: 'Bs.', separator: ",", delimiter: ".")}"]
    data << ['<b>Monto: <b>', "#{payment.mount},00 Bs."] if payment
    data << ["<b>#{payment.transaction_type.capitalize}: <b>", payment.transaction_number ] if payment

    # t = pdf.make_table(data, header: true, row_colors: ["F0F0F0", "FFFFFF"], width: 300, position: :center, cell_style: { inline_format: true, size: 9, align: :center, padding: 3, border_color: '818284'}, :column_widths => {0 => 5, 2 => 120})


    # pdf.table([[t,v]], width: 560, cell_style: {border_width: 0})



    pdf.table data do |t|
      t.width = 540
      t.position = :center
      t.header = false
      # t.row_colors = ["F0F0F0", "FFFFFF"]
      # t.column_widths = {1 => 60, 2 => 220, 5 => 30, 7 => 70}
      t.cell_style = {inline_format: true, size: 11, padding: 3, border_color: 'FFFFFF'}
      # t.column(2).style(:align => :justify)
      t.column(0).style(:align => :right)
      # t.column(1).style(:font_style => :bold)
    end

  end

  def self.banner_width_logo pdf, title = nil, size = nil

    size_logo = size ? size*4 : 50 
    size ||= 12
    pdf.image "app/assets/images/banner_logos_dark.png", position: :center, height: size_logo, valign: :top
    pdf.move_down 3
    pdf.text "UNIVERSIDAD CENTRAL DE VENEZUELA", align: :center, size: size 
    pdf.move_down 3
    pdf.text "Escuela de Idiomas Modernos", align: :center, size: size
    pdf.move_down 3
    pdf.text "FUNDEIM", align: :center, size: size

    pdf.move_down 5
    pdf.text title, align: :center, size: size, style: :bold

    pdf.move_down 5

    # return pdf
  end


  def self.signatures (historial_academico,pdf)
    # -- FIRMAS -----
    # pdf.text "\n\n", :font_size => 8
    # tabla = PDF::SimpleTable.new 
    # tabla.font_size = 11
    # tabla.orientation   = :center
    # tabla.position      = :center
    # tabla.show_lines    = :none
    # tabla.show_headings = false 
    # tabla.shade_rows = :none
    # tabla.column_order = ["nombre", "valor"]

    # tabla.columns["nombre"] = PDF::SimpleTable::Column.new("nombre") { |col|
    #   col.width = 250
    #   col.justification = :center
    # }
    # tabla.columns["valor"] = PDF::SimpleTable::Column.new("valor") { |col|
    #   col.width = 250
    #   col.justification = :center
    # }
    # @persona = (historial_academico.tipo_categoria_id == "NI" || historial_academico.tipo_categoria_id == "TE") ? "Representante" : "Estudiante" 
    # datos = []
    # datos << { "nombre" => to_utf16("<b>__________________________</b>"), "valor" => to_utf16("<b>__________________________</b>") }
    # datos << { "nombre" => to_utf16("Firma #{@persona}"), "valor" => to_utf16("Firma Autorizada y Sello") }
    # tabla.data.replace datos  
    # tabla.render_on(pdf)
    
  end

  protected

  def self.put_profile_image user, pdf
    begin
      if user.profile_image and user.profile_image.attached?
        require 'open-uri'
        pdf.image open(user.profile_image.service_url), at: [420, 710], fit: [60, 95]
      end
      # rescue Prawn::Errors::UnsupportedImageType => e
      # rescue SocketError => e
    rescue Exception => e
      # pdf.image "app/assets/images/foto_perfil_default.png", fit: [55, 70], at: [420, 710]
    end
    
  end

end
