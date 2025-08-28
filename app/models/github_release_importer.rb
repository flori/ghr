# A class responsible for importing GitHub releases into the application.
#
# This class handles the process of fetching new releases or tags from GitHub
# for a given repository and storing them in the database. It supports both
# standard releases and lightweight tags, with configurable filtering based on
# tag names and version requirements. The importer can also trigger notifications
# via configured notifier plugins such as email or JIRA when new releases are found.
#
# @example Initialize and perform import
#   importer = GithubReleaseImporter.new(github_repo: repo, notify: true)
#   importer.perform
class GithubReleaseImporter
  # @param [GithubRepo] github_repo GitHub repo to pull version info from
  # @param [Boolean] notify Set to true to send notifications
  def initialize(github_repo:, notify:)
    @github_repo    = github_repo
    @notify         = notify
    @client         = build_client
    @version_filter = VersionFilter.for_github_repo(@github_repo)
  end

  # Imports all new releases, if any, from github, if their +tag_name+ and
  # +version_requirement+ match.
  def perform
    @github_repo.import_enabled or return
    count = 0
    unless @github_repo.lightweight
      # This creates sparse GithubRelease objects from lightweight tags, if the
      # GithubRepo was configured that way.
      @client.releases(user: @github_repo.user, repo: @github_repo.repo).
        reject(&:prerelease?).
        reject { |release| GithubRelease.exists?(url: release.url) }.
        select {  |release| release.tag_name =~ @version_filter }.
        map { |release| count += 1; add_new_release release: }.
        each { |github_release| notify_about github_release: }
    else
      @client.tags(user: @github_repo.user, repo: @github_repo.repo).
        reject { |tag| GithubRelease.exists?(url: tag.tarball_url) }.
        select {  |tag| tag.name =~ @version_filter }.
        map { |tag| count += 1; add_new_tag tag: }.
        each { |github_release| notify_about github_release: }
    end
    count
  end

  private

  # Returns an array of configured notifiers that are pending notification for
  # this release.
  # The method returns the configured_notifiers from the github_repo if
  # notifications are enabled, otherwise it returns an empty array.
  #
  # @return [ Array<Symbol>, Array<String> ] An array of notifier symbols
  # (e.g., :JIRA, :Email)
  def pending_notifiers
    @notify ? @github_repo.configured_notifiers : []
  end

  # @param release github release to add.
  # @return [GithubRelease] The github_release created in the database.
  def add_new_release(release:)
    github_release = GithubRelease.new(
      url:               release.url,
      html_url:          release.html_url,
      name:              release.name.presence || release.tag_name,
      tag_name:          release.tag_name,
      body:              release.body,
      published_at:      release.published_at,
      pending_notifiers:
    )
    @github_repo.github_releases << github_release
    github_release
  end

  # @param tag github tag to add as a release.
  # @return [GithubRelease] The github_release created in the database.
  def add_new_tag(tag:)
    html_url = "https://github.com/%s/%s/releases/tag/%s" % [
      @github_repo.user,
      @github_repo.repo,
      tag.name,
    ]
    body = "New tag %s was pushed." % tag.name
    github_release = GithubRelease.new(
      url:               tag.tarball_url,
      html_url:          html_url,
      name:              tag.name,
      tag_name:          tag.name,
      body:              body,
      published_at:      Time.now,
      pending_notifiers:
    )
    @github_repo.github_releases << github_release
    github_release
  end

  # Notifies for all enabled plugins
  #
  # @param [GithubRelease] github_release to maybe notify about
  def notify_about(github_release:)
    @notify or return
    github_release.pending_notifiers.each do |plugin|
      case plugin
      when Notifier::Plugin::JIRA
        github_release.do_notify_via_jira
      when Notifier::Plugin::Email
        github_release.do_notify_via_email
      else
        Rails.logger.warn "Invalid plugin #{plugin.class} ignored"
      end
    end
  end

  # @return [Octokit::Client] to use for github
  def build_client
    GithubClient.connect
  end
end
