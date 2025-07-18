class ApplicationMailer < ActionMailer::Base
  helper MailerHelper

  default from: -> {
    "noreply@%s" % Rails.application.config.action_mailer.default_url_options[:host]
  }
  layout "mailer"
end
