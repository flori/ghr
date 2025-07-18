class RenameNotifyJIRAToNotifyInGithubRelease < ActiveRecord::Migration[8.0]
  def change
    rename_column :github_releases, :notify_jira, :notify
  end
end
