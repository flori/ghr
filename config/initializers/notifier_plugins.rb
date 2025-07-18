if email = ENV['EMAIL_NOTIFY_USER'].full?
  Rails.application.config.to_prepare do
    NotificationMailer.notify_user = email
  end
end
