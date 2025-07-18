class RemoveColumnNotifyJIRAFromGithubRepo < ActiveRecord::Migration[8.0]
  def up
    GithubRepo.find_each do |github_repo|
      github_repo.configured_notifier_jira = true
      github_repo.save!
    end
    remove_column :github_repos, :notify_jira
  end
end
