class GithubRepo < ApplicationRecord
  validates :user, presence: true
  validates :repo, presence: true, uniqueness: { scope: :user }

  has_many :github_releases, dependent: :destroy

  has_set :configured_notifiers, class_name: Notifier::Plugin

  # @return [User, nil] the user with the given +"user:repo"+ name if found.
  def self.find_by_param(param)
    user, repo = param.split(?:, 2)
    find_by(user:, repo:)
  end

  # Adds a new repository to be watched to the database.
  #
  # @param user [String] The GitHub user to which the repo belongs.
  # @param repo [String] The name of the repository.
  # @param tag_filter [String] A filter for tags, such as +"\\Av(\\d+.\\d+.\\d+)\\z"+.
  # @param version_requirement [Array<String>] A list of version requirements for the release, e. g. "~>10.3"
  # @param lightweight [Boolean] Whether to switch on the lightweight tag mode rather than the release mode.
  # @return [GithubRepo] The created GitHub repository.
  def self.add(user:, repo:, tag_filter:, configured_notifiers:, version_requirement: [], lightweight: false)
    github_repo = create!(user:, repo:, tag_filter:, configured_notifiers:, version_requirement:, lightweight:)
    GithubReleaseImporter.new(github_repo:, notify: false).perform
    github_repo
  end

  # Returns an array of version strings that match the tag_filter and are
  # associated with releases in this repository, sorted by the version numbers.
  def versions
    github_releases&.map { _1.version(tag_filter) }&.compact&.sort
  end

  # Reimports all releases for this repository from GitHub.
  #
  # This method destroys all existing releases and then imports new ones using
  # the GithubReleaseImporter.
  def reimport
    github_releases.destroy_all
    GithubReleaseImporter.new(github_repo: self, notify: false).perform
  end

  # Returns a string representation of this GithubRepo instance
  #
  # @return [ String ] A string in the format "user: foo, repo: bar, releases: 66, last_release: v1.2.3
  def to_s
    releases     = versions
    last_release = releases&.last
    {
      user:, repo:, releases: releases&.size.to_i,
      last_release: last_release || 'n/a'
    }.map { "%s: %s" % _1.flatten } * ', '
  end

  # @return String the unique identifier for this repository in the form of +"user:repo"+.
  def to_param
    "#{user}:#{repo}"
  end
end
