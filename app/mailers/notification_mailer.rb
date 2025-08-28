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
  # @param notifier [ Object ] the notifier object containing release information
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
