class RemoveNotifyFromGithubRelease < ActiveRecord::Migration[8.0]
  def up
    remove_column :github_releases, :notify, :boolean
  end
end
