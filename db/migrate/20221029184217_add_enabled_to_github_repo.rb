class AddEnabledToGithubRepo < ActiveRecord::Migration[7.0]
  def change
    add_column :github_repos, :enabled, :boolean, null: false, default: true
  end
end
