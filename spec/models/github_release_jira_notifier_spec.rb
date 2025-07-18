require 'rails_helper'

RSpec.describe GithubReleaseJIRANotifier, type: :model do
  let :github_repo do
    GithubRepo.create(
      user: 'foo',
      repo: 'bar',
      tag_filter: tf = '\Av(0)\.(\d+)\.(\d+)\z',
      configured_notifiers: %i[ JIRA ],
      version_requirement: %w[ ~>0.44' ]
    )
  end

  it "doesn't notify JIRA if pending_notifiers was empty" do
    github_release = GithubRelease.new pending_notifiers: []
    expect(JIRAClient).not_to receive(:issue!)
    described_class.new(github_release:).perform
  end

  it 'notifies JIRA if pending_notifiers was [ :JIRA ]' do
    github_release = GithubRelease.new(
      github_repo:,
      published_at: Time.parse('2011-11-11 11:11:11Z'),
      body: 'foo body',
      tag_name: 'v1.2.3',
      name: 'The numbers release',
      html_url: 'https://foo.bar.com/blubs',
      url: 'https://foo.bar.com/blubs',
      pending_notifiers: %i[ JIRA ],
    )
    expect(JIRAClient).to receive(:issue!).with(
      summary: "New release foo/bar v1.2.3: The numbers release",
      description: "See the [github release page](https://foo.bar.com/blubs) for **v1.2.3** here,\nPublished at _2011-11-11T11:11:11+00:00_\n\nfoo body\n\nSee the [ghr URL](http://example.com/repos/foo:bar) for more information about _foo/bar_ releases."
    )
    expect {
      described_class.new(github_release:).perform
    }.to change { github_release.pending_notifier_jira }.from(true).to(false)
  end
end
