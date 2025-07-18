class GithubReleaseEmailNotifier
  include GithubReleaseNotifier

  # Perform the notify via E-Mail action for a given GitHub release if it is
  # pending.
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
