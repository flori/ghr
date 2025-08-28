# A notifier class responsible for creating JIRA issues about GitHub releases.
#
# This class implements the GithubReleaseNotifier module to provide
# JIRA-specific notification functionality. It handles the process of
# generating and submitting issue reports to a JIRA instance when new
# GitHub releases are detected for tracked repositories.
#
# @see GithubReleaseNotifier
class GithubReleaseJIRANotifier
  include GithubReleaseNotifier

  # Performs JIRA notification for a GitHub release.
  #
  # This method checks if JIRA notification is pending for the release and if
  # the JIRA client is configured. If both conditions are met, it creates a
  # JIRA issue using the release details. The method also updates the release's
  # notification status after attempting to create the JIRA issue.
  #
  # @return [GithubRelease, nil] the GitHub release instance that was processed
  #   or nil
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
