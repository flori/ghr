# The `GithubReleaseNotifier` module provides methods for generating
# notifications about new GitHub releases. It offers:
# - A unique repository identifier in the format "user/repo"
# - A concise summary string describing the release
# - A detailed description that includes release details and a link to the
# GitHub release page
#
# The module is intended to be included into notifier classes. Notifier classes
# must implement the `perform` method, which should utilize the provided
# methods to send notifications via their specific plugins (e.g., JIRA,
# Slack, Email).
module GithubReleaseNotifier
  include Rails.application.routes.url_helpers

  # @return [Hash] The default URL options configured for ActionMailer.
  def default_url_options
    Rails.configuration.action_mailer.default_url_options
  end

  # @param [GithubRelease] github_release about which to eventually notify
  # about.
  def initialize(github_release:)
    @github_release = github_release
  end

  implement :perform, :submodule

  # @return [String] the github URL for this release.
  def release_url
    @github_release.url
  end

  # @return [String] the pair "user/repo" that identifies this repo on github.
  def repo
    "%s/%s" % [
      @github_release.github_repo.user,
      @github_release.github_repo.repo,
    ]
  end

  # @return [String] the summary for the GitHub release used for the notifiication.
  def summary
    "New release #{repo} #{@github_release.tag_name}: #{@github_release.name}"
  end

  # @return [String] The URL pointing to your application's page for the
  # specific GitHub repository.
  def app_url
    repo_url(@github_release.github_repo.to_param)
  end

  # @return [String] the description containing more information and a link to
  # the github URL that is used for the notification.
  def description
    [
      "See the [github release page](#{@github_release.html_url}) for **#{@github_release.tag_name}** here,",
      "Published at _#{@github_release.published_at.localtime.iso8601}_",
      "",
      @github_release.body,
      "",
      "See the [ghr URL](#{app_url}) for more information about _#{repo}_ releases."
    ] * ?\n
  end
end
