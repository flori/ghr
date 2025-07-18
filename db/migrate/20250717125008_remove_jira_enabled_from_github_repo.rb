class RemoveJIRAEnabledFromGithubRepo < ActiveRecord::Migration[8.0]
  def change
    remove_column :github_repos, :jira_enabled, :boolean
  end
end
