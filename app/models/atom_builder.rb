class AtomBuilder
  # @param github_releases [Enumerable] an enumerable containing the github
  #                                     releases for the feed.
  # @param host [String] the hostname this atom feed will be published on, e.g. +request.host+.
  def initialize(github_releases, host: 'localhost')
    @github_releases = github_releases
    @host            = host
  end

  # @return [String] the atom feed for the +github_releases+
  def to_atom
    feed = Atom::Feed.new
    @github_releases.empty? and return feed.to_s

    github_repo = @github_releases.first.github_repo
    feed.title = "Github Releases of %s" % github_repo.to_param
    feed.updated = github_repo.github_releases.maximum(:published_at)
    feed.authors.new name: github_repo.user
    feed.id = repo_url(github_repo)
    url = Rails.application.routes.url_helpers.repo_url(github_repo.to_param, host: @host)
    feed.links.new href: url, rel: 'self'

    @github_releases.each do |github_release|
      e = Atom::Entry.new
      e.title = "%s (%s)" % [ github_release.name, github_release.tag_name ]
      e.id = github_release.url
      e.links.new href: github_release.html_url, rel: 'alternate'
      e.content = Kramdown::Document.new(github_release.body.to_s).to_html
      e.content.type = 'html'
      e.updated = github_release.published_at
      feed << e
    end
    feed.to_s
  end

  private

  # @param [GithubRepo] github_repo
  #   The GitHub repository for which to retrieve the URL
  # @return [String]
  #   The URL of the GitHub repository
  def repo_url(github_repo)
    GithubClient.connect.repo(user: github_repo.user, repo: github_repo.repo).url
  end
end
