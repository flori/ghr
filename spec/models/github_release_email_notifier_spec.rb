require 'rails_helper'

describe GithubReleaseEmailNotifier, type: :model do
  let :github_repo do
    GithubRepo.create(
      user: 'foo',
      repo: 'bar',
      tag_filter: tf = '\Av(0)\.(\d+)\.(\d+)\z',
      configured_notifiers: %i[ Email ],
      version_requirement: %w[ ~>0.44' ]
    )
  end

  it "doesn't notify Email if pending_notifiers was empty" do
    github_release = GithubRelease.new pending_notifiers: []
    expect(NotificationMailer).not_to receive(:with)
    described_class.new(github_release:).perform
  end

  it 'notifies Email if pending_notifiers was [ :Email ]' do
    github_release = GithubRelease.new(
      github_repo:,
      published_at: Time.parse('2011-11-11 11:11:11Z'),
      body: 'foo body',
      tag_name: 'v1.2.3',
      name: 'The numbers release',
      html_url: 'https://foo.bar.com/blubs',
      url: 'https://foo.bar.com/blubs',
      pending_notifiers: %i[ Email ],
    )

    expect(NotificationMailer).to receive(:configured?).and_return true
    expect(NotificationMailer).to receive(:with).and_return(double.as_null_object)
    expect {
      described_class.new(github_release:).perform
    }.to change { github_release.pending_notifier_email }.from(true).to(false)
  end
end
