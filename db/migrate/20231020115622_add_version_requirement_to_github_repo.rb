class AddVersionRequirementToGithubRepo < ActiveRecord::Migration[7.0]
  def change
    add_column :github_repos, :version_requirement, :string, array: true, default: []
  end
end
