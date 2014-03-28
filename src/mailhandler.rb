require 'mail'

# Handles all email transmissions
module MailHandler

  # Sends an email from notifications
  #
  # @param send_to [String] email address to send message to
  # @param mail_subject [String] subject of the email
  # @param mail_body [String] body of the email 
  def MailHandler.send(send_to, mail_subject, mail_body)
    Mail.deliver do
      from 'notifications@bookmarket.webhop.org'
      to send_to
      subject mail_subject
      body mail_body
    end
  end

  # Sends an account verification email
  #
  # @param email [String] email address to send verification to
  # @param code [String] verification code to send
  def MailHandler.send_verification(email, code)
    body = "To verify you account please follow this link: http://bookmarket.webhop.org:4567/verify/#{code}"
    MailHandler.send(email, "Account Verification", body)
  end

end
