# A mailer class responsible for sending email notifications about GitHub
# releases.
#
# This class handles the generation and delivery of email messages to
# configured recipients when new GitHub releases are detected for tracked
# repositories. It inherits from ApplicationMailer and provides functionality
# specific to GitHub release notifications.
class NotificationMailer < ApplicationMailer
  class << self
    # Checks whether email notification is enabled.
    #
    # @return [ TrueClass, FalseClass ] true if email notifications are
    # enabled, false otherwise
    def configured?
      !!GhrConfig::EMAIL::ENABLED?
    end
  end

  # The github_release_email method generates and sends an email notification
  # for a GitHub release using the provided notifier parameters.
  #
  # @return [ Mail::Message ] the generated email message
  def github_release_email
    notifier     = params[:notifier]
    @summary     = notifier.summary
    @description = notifier.description
    to           = notify_user
    subject      = @summary
    mail(to:, subject:)
  end

  private

  def notify_user
    GHR::EMAIL::NOTIFY_USER
  end
end
