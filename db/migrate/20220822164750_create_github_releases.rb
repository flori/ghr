class CreateGithubReleases < ActiveRecord::Migration[7.0]
  def change
    create_table :github_releases do |t|
      t.references :github_repo, null: false
      t.string :url, unique: true, null: false
      t.string :html_url, null: false
      t.string :name, null: false
      t.string :tag_name, null: false
      t.datetime :published_at, null: false
      t.text :body
      t.boolean :notify_jira, null: false, default: false

      t.timestamps
    end
  end
end
