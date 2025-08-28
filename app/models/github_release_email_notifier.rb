# A notifier class responsible for sending email notifications about GitHub
# releases.
#
# This class implements the GithubReleaseNotifier module to provide
# email-specific notification functionality. It handles the process of
# generating and delivering email messages to configured recipients when new
# GitHub releases are detected for tracked repositories.
#
# @see GithubReleaseNotifier
class GithubReleaseEmailNotifier
  include GithubReleaseNotifier

  # Performs email notification for a GitHub release.
  #
  # This method checks if email notification is pending for the release and if
  # the notification mailer is configured. If both conditions are met, it sends
  # an email notification using the configured mailer. The method also updates
  # the release's notification status after attempting to send the email.
  #
  # @return [GithubRelease, nil] the GitHub release instance that was processed
  # or nil
  def perform
    @github_release.pending_notifier_email? or return
    if NotificationMailer.configured?
      NotificationMailer.with(notifier: self).github_release_email.deliver
      Rails.logger.info "Sent an e-mail for #{release_url.inspect}"
    else
      Rails.logger.info "E-mail notifications are not configured, do not send for #{release_url.inspect}"
    end
    @github_release.pending_notifier_email = false
    @github_release.save!
    @github_release
  end
end
