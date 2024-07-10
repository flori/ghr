require 'rails_helper'

RSpec.describe GithubRelease, type: :model do
  let :github_repo do
    GithubRepo.create user: 'foo', repo: 'bar'
  end

  let :github_release do
    described_class.new(
      url:          'https://foo.bar',
      html_url:     'https://foo.baz',
      name:         'The Evil',
      tag_name:     'v6.6.6',
      published_at: Time.parse('2011-11-11T11:11:11Z'),
      body:         'test',
    )
  end

  it 'can be created' do
    github_release.github_repo = github_repo
    github_release.save!
  end

  it 'can be added to a github_repo' do
    expect { github_repo.github_releases << github_release }.to change {
      github_repo.reload.github_releases.size
    }.from(0).to(1)
  end

  it 'it touches github_repo if added to a it' do
    old_updated_at = github_repo.updated_at
    expect { github_repo.github_releases << github_release }.to change {
      github_repo.updated_at
    }.from(old_updated_at)
  end

  context 'Notify JIRA' do
    before do
      github_repo.github_releases << github_release
    end

    describe '#do_notify_jira' do
      it 'it notifies jira if notify_jira is true' do
        github_release.update(notify_jira: true)
        expect(JIRAClient).to receive(:issue!)
        github_release.do_notify_jira
      end

      it "it doesn't notify jira if notify_jira is false" do
        github_release.update(notify_jira: false)
        expect(JIRAClient).not_to receive(:issue!)
        github_release.do_notify_jira
      end
    end

    describe '#do_notify_jira!' do
      it "it does notify jira even if notify_jira is false" do
        github_release.update(notify_jira: false)
        expect(JIRAClient).to receive(:issue!)
        github_release.do_notify_jira!
      end
    end
  end
end
