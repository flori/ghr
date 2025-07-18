class GithubReleaseJIRANotifier
  include GithubReleaseNotifier

  # Perform the notify via JIRA action for a given GitHub release if it is
  # pending.
  def perform
    @github_release.pending_notifier_jira? or return
    if JIRAClient.configured?
      JIRAClient.issue!(
        summary: summary,
        description: description
      )
      Rails.logger.info "Created an issue for #{release_url.inspect}"
    else
      Rails.logger.info "JIRA is not configured omitting JIRA notification for #{release_url.inspect}"
    end
    @github_release.pending_notifier_jira = false
    @github_release.save!
    @github_release
  end
end
