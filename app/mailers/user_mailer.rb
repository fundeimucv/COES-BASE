class UserMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.welcome.subject
  #
  def welcome user
    mail(to: user.email_desc, subject: "¡Bienvenido a Coes!")
  end

  def general user, msg
    @msg = msg
    mail(to: user.email_desc, subject: "¡Correo General de Coes!")
  end  

  def enroll_confirmation(id)
    enroll_academic_process = EnrollAcademicProcess.find id
    user = enroll_academic_process.user
    escuela = enroll_academic_process.school
    @sections = enroll_academic_process.sections

    @escuela_name = escuela.name
    @periodo_name = enroll_academic_process.academic_process.process_name
    @nombre = user.nick_name
    @genero = user.genero
    mail(to: user.email_desc, subject: "¡Confirmación de inscripción en #{@escuela_name} para el Período #{@periodo_name} COES!")
    
  end

  def actas_generation_complete(user, blob, filename)
    @user = user
    @filename = filename
    @blob = blob
    
    # Generar URL de descarga para el blob
    @download_url = Rails.application.routes.url_helpers.rails_blob_url(
      blob,
      only_path: true
    )
    
    # Adjuntar el archivo al correo
    attachments[filename] = blob.download
    
    mail(
      to: @user.email,
      subject: "Generación de Actas Completada - #{@filename}"
    )
  end

end
