if email = GhrConfig::EMAIL::NOTIFY_USER?
  Rails.application.config.to_prepare do
    NotificationMailer.notify_user = email
  end
end
