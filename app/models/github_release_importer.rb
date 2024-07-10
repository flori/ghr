class GithubReleaseImporter
  # @param [GithubRepo] github_repo GitHub repo to pull version info from
  # @param [Boolean] notify_jira Set to true to send a notification to JIRA
  def initialize(github_repo:, notify_jira:)
    @github_repo    = github_repo
    @notify_jira    = notify_jira
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
        each { |github_release| notify_jira_about github_release: }
    else
      @client.tags(user: @github_repo.user, repo: @github_repo.repo).
        reject { |tag| GithubRelease.exists?(url: tag.tarball_url) }.
        select {  |tag| tag.name =~ @version_filter }.
        map { |tag| count += 1; add_new_tag tag: }.
        each { |github_release| notify_jira_about github_release: }
    end
    count
  end

  private

  # @param release github release to add.
  # @return [GithubRelease] The github_release created in the database.
  def add_new_release(release:)
    github_release = GithubRelease.new(
      url:          release.url,
      html_url:     release.html_url,
      name:         release.name.presence || release.tag_name,
      tag_name:     release.tag_name,
      body:         release.body,
      published_at: release.published_at,
      notify_jira:  @notify_jira
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
      url:          tag.tarball_url,
      html_url:     html_url,
      name:         tag.name,
      tag_name:     tag.name,
      body:         body,
      published_at: Time.now,
      notify_jira:  @notify_jira
    )
    @github_repo.github_releases << github_release
    github_release
  end

  # Notifies JIRA, eventually, by calling {GithubRelease#do_notify_jira}
  #
  # @param [GithubRelease] github_release to maybe notify about
  def notify_jira_about(github_release:)
    @notify_jira and github_release.do_notify_jira
  end

  # @return [Octokit::Client] to use for github
  def build_client
    GithubClient.connect
  end
end
