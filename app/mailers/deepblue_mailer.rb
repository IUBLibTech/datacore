# frozen_string_literal: true

class DeepblueMailer < ApplicationMailer
  default from: Deepblue::EmailHelper.notification_email

  layout "mailer.html"

  def send_an_email( to:, from:, subject:, body: )
    begin
      mail( to: to, from: from, subject: subject, body: body )
    rescue => e
      Rails.logger.error "Error in DeepblueMailer#send_an_email"
      Rails.logger.error "#{e.class}: #{e.inspect}"
      nil
    end
  end
end
