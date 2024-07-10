class AddLightweightToGithubRepo < ActiveRecord::Migration[7.0]
  def change
    add_column :github_repos, :lightweight, :boolean, null: false, default: false
  end
end
