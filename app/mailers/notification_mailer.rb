class NotificationMailer < ApplicationMailer
  class << self
    attr_accessor :notify_user

    def configured?
      ENV['EMAIL_NOTIFY_SMTP_URL'].present? && notify_user.present?
    end
  end

  def github_release_email
    notifier     = params[:notifier]
    @summary     = notifier.summary
    @description = notifier.description
    to           = self.class.notify_user
    subject      = @summary
    mail(to:, subject:)
  end
end
