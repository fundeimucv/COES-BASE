# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/welcome
  def welcome 
    UserMailer.welcome User.first
  end

  def enroll_confirmation
    enroll = EnrollAcademicProcess.find params[:enroll_id]
    UserMailer.enroll_confirmation(params[:enroll_id])
  end

end
