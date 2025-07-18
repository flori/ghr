# Preview all emails at http://localhost:8123/rails/mailers/notification_mailer
class NotificationMailerPreview < ActionMailer::Preview
  def read_fixture(name)
    path = Pathname.new(__FILE__).dirname + '..' + '..' + 'fixtures' + name
    JSON(File.read(path))
  end

  # Preview this email at http://localhost:8123/rails/mailers/notification_mailer/github_release_email
  def github_release_email
    github_release = OpenStruct.new(
      {
        github_repo: OpenStruct.new(user: 'metabase', repo: 'metabase', to_param: 'metabase:metabase'),
        published_at: Time.now
      } | read_fixture('releases.json').first
    )
    notifier = GithubReleaseEmailNotifier.new(github_release:)
    NotificationMailer.notify_user = 'thomas.ester@example.com'
    NotificationMailer.with(notifier:).github_release_email
  end
end
