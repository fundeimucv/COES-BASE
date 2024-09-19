# Preview all emails at http://localhost:3000/rails/mailers/student_mailer
class StudentMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/student_mailer/preinscrito
  # Preview this email at http://localhost:3000/rails/mailers/student_mailer/preinscrito?enroll_id=70216
  def preinscrito
    enroll = EnrollAcademicProcess.find params[:enroll_id]
    StudentMailer.preinscrito enroll
  end

end
