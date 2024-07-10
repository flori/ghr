class AddJIRAEnabledToGithubRepo < ActiveRecord::Migration[7.0]
  def change
    add_column :github_repos, :jira_enabled, :boolean, void: false, default: true
  end
end
