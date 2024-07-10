class GithubReleaseJIRANotifier
  # @param [GithubRelease] github_release about which to eventually notify
  # JIRA.
  def initialize(github_release:)
    @github_release = github_release
  end

  # Perform the notify JIRA action for a given GitHub release, unless
  # GitHubRelease#notify_jira was false. Otherwise GitHubRelease#notify_jira is
  # set to false, guaranteeing that only one notification via a JIRA issue is
  # sent.
  def perform
    @github_release.notify_jira or return
    release_url = @github_release.url.inspect
    if JIRAClient.configured?
      JIRAClient.issue!(
        summary: summary,
        description: description
      )
      Rails.logger.info "Created an issue for #{release_url}"
    else
      Rails.logger.info "JIRA is not configured omitting JIRA notification for #{release_url}."
    end
    @github_release.update!(notify_jira: false)
    @github_release
  end

  private

  # @return [String] the pair "user/repo" that identifies this repo on github.
  def repo
    "%s/%s" % [
      @github_release.github_repo.user,
      @github_release.github_repo.repo,
    ]
  end

  # @return [String] the summary of the GitHub release used for the created
  # JIRA issue
  def summary
    "New release #{repo} #{@github_release.tag_name}: #{@github_release.name}"
  end


  # @return [String] the description containing more information and a link to
  # the github URL.
  def description
    [
      "See #{@github_release.html_url}",
      "Published at _#{@github_release.published_at.localtime.iso8601}_",
      "",
      @github_release.body, # TODO maybe convert this from markdown to ADF
    ] * ?\n
  end
end
