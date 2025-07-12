class RemoveColumnNotifyJIRAFromGithubRepo < ActiveRecord::Migration[8.0]
  def up
    remove_column :github_repos, :notify_jira
  end
end
