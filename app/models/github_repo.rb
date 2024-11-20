class GithubRepo < ApplicationRecord
  validates :user, presence: true
  validates :repo, presence: true, uniqueness: { scope: :user }

  has_many :github_releases, -> { order(tag_name: :desc) }, dependent: :destroy

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
  def self.add(user:, repo:, tag_filter:, version_requirement: [], lightweight: false)
    github_repo = create!(user:, repo:, tag_filter:, lightweight:, version_requirement:)
    GithubReleaseImporter.new(github_repo:, notify_jira: false).perform
    github_repo
  end

  # @return String the unique identifier for this repository in the form of +"user:repo"+.
  def to_param
    "#{user}:#{repo}"
  end
end
