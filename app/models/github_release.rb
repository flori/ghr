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

  def version(tag_filter)
    TagFilter.new(tag_filter).version(tag_name)
  end

  def as_json(options = {})
    super(except: :pending_notifiers_bitfield).merge(
      pending_notifiers: pending_notifiers.map(&:name)
    )
  end
end
