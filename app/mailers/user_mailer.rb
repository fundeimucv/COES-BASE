class UserMailer < ApplicationMailer
  default from: "coes.fau@gmail.com"
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.welcome.subject
  #
  def welcome
    @greeting = "Hi"

    mail to: "moros.daniel@gmail.com"
  end
end
