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

  # Returns a string representation of the GitHub release
  #
  # This method generates a formatted string containing key information about
  # the GitHub release, including the repository identifier, version, and
  # publication timestamp.
  #
  # @return [String] a formatted string with release information in the format
  #   "repo: user/repo, version: 1.2.3, published_at: 2023-01-01T12:00:00Z"
  def to_s
    {
      repo: to_param,
      version:,
      published_at: published_at.iso8601
    }.map { "%s: %s" % _1.flatten } * ', '
  end

  # Returns a string representation of this object
  #
  # This method provides a detailed string formatting of the object's state,
  # including its class name and formatted information returned by the #to_s
  # method.
  #
  # @return [String] a formatted string containing the object's class name and
  #   state information in the format "#<ClassName: text_from_to_s>"
  def inspect
    "#<#{self.class}: #{to_s}>"
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
