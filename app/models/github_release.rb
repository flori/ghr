class GithubRelease < ApplicationRecord
  belongs_to :github_repo, touch: true
  validates :github_repo_id, presence: true
  validates :url, presence: true, uniqueness: true
  validates :html_url, presence: true
  validates :name, presence: true
  validates :tag_name, presence: true
  validates :published_at, presence: true

  # Notify JIRA of new release, if +notify_jira+ isn't set to false.
  def do_notify_jira
    GithubReleaseJIRANotifier.new(github_release: self).perform
  end

  # Notify JIRA of new release, after setting +notify_jira+ to true. This is
  # mostly useful if you want to be notified again or for an older release /
  # one you skipped before.
  def do_notify_jira!
    self.update(notify_jira: true)
    do_notify_jira
  end
end
