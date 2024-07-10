require 'rails_helper'

RSpec.describe GithubReleaseJIRANotifier, type: :model do
  it "doesn't notify JIRA if notify_jira was false" do
    github_release = GithubRelease.new notify_jira: false
    expect(JIRAClient).not_to receive(:issue!)
    described_class.new(github_release:).perform
  end

  it 'notifies JIRA if notify_jira was true' do
    github_release = GithubRelease.new(
      notify_jira: true,
      published_at: Time.parse('2011-11-11 11:11:11Z'),
      body: 'foo body',
      tag_name: 'v1.2.3',
      name: 'The numbers release',
      html_url: 'https://foo.bar.com/blubs',
    )
    github_release.github_repo = GithubRepo.new(user: 'userfoo', repo: 'repobar')
    expect(github_release).to receive(:update!).with(notify_jira: false)
    expect(JIRAClient).to receive(:issue!).with(
      summary: "New release userfoo/repobar v1.2.3: The numbers release",
      description: "See https://foo.bar.com/blubs\nPublished at _2011-11-11T11:11:11+00:00_\n\nfoo body"
    )
    described_class.new(github_release:).perform
  end
end

