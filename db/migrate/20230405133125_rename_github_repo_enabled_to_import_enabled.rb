class RenameGithubRepoEnabledToImportEnabled < ActiveRecord::Migration[7.0]
  def change
    rename_column :github_repos, :enabled, :import_enabled
  end
end
