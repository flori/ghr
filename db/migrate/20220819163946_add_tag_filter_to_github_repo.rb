class AddTagFilterToGithubRepo < ActiveRecord::Migration[7.0]
  def change
    add_column :github_repos, :tag_filter, :string, null: false, default: ''
  end
end
