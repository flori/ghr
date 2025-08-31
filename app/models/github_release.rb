# A model representing a GitHub release associated with a GitHub repository.
#
# This class stores information about individual releases from GitHub repositories,
# including metadata such as release names, tag names, publication dates, and
# release bodies. It also manages notifications for these releases via various
# notifier plugins like email and JIRA.
#
# The model is designed to work in conjunction with GithubRepo to track and
# manage release information, ensuring that each release is uniquely identified
# by its URL and properly associated with its parent repository.
#
# @attr [GithubRepo] github_repo the repository this release belongs to
# @attr [String] url the unique URL of the release
# @attr [String] html_url the HTML URL for viewing the release on GitHub
# @attr [String] name the name of the release
# @attr [String] tag_name the tag name used for the release
# @attr [String] body the body content of the release
# @attr [DateTime] published_at the date and time when the release was published
# @attr [Array<Symbol>] pending_notifiers the list of notifier plugins that should handle this release
class GithubRelease < ApplicationRecord
  belongs_to :github_repo, touch: true
  validates :github_repo_id, presence: true
  validates :url, presence: true, uniqueness: true
  validates :html_url, presence: true
  validates :name, presence: true
  validates :tag_name, presence: true
  validates :published_at, presence: true

  has_set :pending_notifiers, class_name: Notifier::Plugin

  # Notifies JIRA about the release if pending_notifier_jira is true.
  def do_notify_via_jira
    GithubReleaseJIRANotifier.new(github_release: self).perform
  end

  # Forces notification via JIRA even if pending_notifier_jira is false.
  def do_notify_via_jira!
    self.pending_notifier_jira = true
    save!
    do_notify_via_jira
  end

  # Notifies about the release via email using the GithubReleaseEmailNotifier.
  def do_notify_via_email
    GithubReleaseEmailNotifier.new(github_release: self).perform
  end

  # The do_notify_via_email! method forces the notification via email for this release
  # regardless of the pending_notifier_email flag state.
  def do_notify_via_email!
    self.pending_notifier_email = true
    save!
    do_notify_via_email
  end

  # Returns the version string for this GitHub release based on the provided
  # tag filter.
  #
  # This method utilizes a TagFilter instance to extract and process the
  # version information from the release's tag name, applying the specified tag
  # filter to determine the relevant portion of the tag for version
  # identification.
  #
  # @param tag_filter [String, Regexp] the tag filter to use for extracting
  # version information
  # @return [Tins::StringVersion::Version, NilClass] a version object if the
  # tag matches the filter, or nil if no valid version could be extracted
  def version(tag_filter = github_repo.tag_filter)
    TagFilter.new(tag_filter).version(tag_name)
  end

  # Converts the GitHub release to a JSON representation.
  #
  # This method extends the default JSON serialization by including the names
  # of the pending notifiers associated with this release. It excludes the
  # internal bitfield attribute and adds a formatted array of notifier names
  # for easier consumption.
  #
  # @param options [Hash] additional options to pass to the superclass
  # implementation
  #
  # @return [Hash] a hash representation of the GitHub release including
  # pending notifier names
  def as_json(options = {})
    super(except: :pending_notifiers_bitfield).merge(
      pending_notifiers: pending_notifiers.map(&:name)
    )
  end
end
