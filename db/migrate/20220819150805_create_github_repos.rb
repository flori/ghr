class CreateGithubRepos < ActiveRecord::Migration[7.0]
  def change
    create_table :github_repos do |t|
      t.string :user, null: false
      t.string :repo, null: false
      t.boolean :notify_jira, null: false, default: false

      t.timestamps
    end
    add_index :github_repos, [:user, :repo], unique: true
  end
end
