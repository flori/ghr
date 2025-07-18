class AddNotifierPluginBitfieldToGithubRelease < ActiveRecord::Migration[8.0]
  def change
    add_column :github_releases, :pending_notifiers_bitfield, :integer, null: false, default: 0
  end
end
