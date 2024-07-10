require 'rails_helper'

RSpec.describe GithubReleaseImporter, type: :model do
  let :github_repo do
    GithubRepo.create user: 'metabase', repo: 'metabase', tag_filter: '\Av(.+)'
  end

  it 'will import when github_repo is import_enabled' do
    github_release_importer = described_class.new(github_repo:, notify_jira: true)
    expect(github_release_importer.instance_variable_get(:@client)).to receive(:releases).and_return([])
    expect(github_release_importer.perform).to be_truthy
  end

  it "won't import when github_repo is not import_enabled" do
    github_repo.import_enabled = false
    github_release_importer = described_class.new(github_repo:, notify_jira: true)
    expect(github_release_importer.perform).to be_nil
  end

  context 'Releases' do
    before do
      stub_request(:get, "https://api.github.com/repos/metabase/metabase/releases?per_page=100").
        with(headers: {
          'Accept'=>'application/vnd.github.v3+json',
          'Content-Type'=>'application/json',
        }).
        to_return(status: 200, body: fixture('releases.json'), headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, "https://api.github.com/repos/metabase/metabase/tags?per_page=100").
        with(headers: {
          'Accept'=>'application/vnd.github.v3+json',
          'Content-Type'=>'application/json',
        }).
        to_return(status: 200, body: fixture('tags.json'), headers: { 'Content-Type' => 'application/json' })
    end

    it 'can import new releases from github' do
      github_release_importer = described_class.new(github_repo:, notify_jira: false)
      expect { github_release_importer.perform }.to change {
        github_repo.reload.github_releases.size
      }.from(0).to(1)
    end

    it 'can import new releases and notify jira' do
      expect(GithubReleaseJIRANotifier).to receive(:new).and_return double(perform: double)
      github_release_importer = described_class.new(github_repo:, notify_jira: true)
      github_release_importer.perform
    end

    it 'can import new releases and not notify jira' do
      expect(GithubReleaseJIRANotifier).not_to receive(:new)
      github_release_importer = described_class.new(github_repo:, notify_jira: false)
      github_release_importer.perform
    end

    context 'Tags (lightweight)' do
      before do
        stub_request(:get, "https://api.github.com/repos/metabase/metabase/tags?per_page=100").
          with(headers: {
            'Accept'=>'application/vnd.github.v3+json',
            'Content-Type'=>'application/json',
          }).
          to_return(status: 200, body: fixture('tags.json'), headers: { 'Content-Type' => 'application/json' })
      end

      it 'can import new tags from github' do
        github_repo.update(lightweight: true)
        github_release_importer = described_class.new(github_repo:, notify_jira: false)
        expect { github_release_importer.perform }.to change {
          github_repo.reload.github_releases.size
        }.from(0).to(1)
      end
    end
  end

  context 'Github Client' do
    context 'without access token' do
      after do
        GithubClient.disconnect
      end

      it 'works' do
        github_release_importer = described_class.new(github_repo:, notify_jira: false)
        client = github_release_importer.send(:build_client)
        expect(client.access_token).to be_nil
      end
    end

    context 'with access token' do
      around do |e|
        ENV['GHR_GITHUB_PERSONAL_ACCESS_TOKEN'] = 'foobar'
        e.run
        ENV.delete('GHR_GITHUB_PERSONAL_ACCESS_TOKEN')
      end

      it 'works' do
        github_release_importer = described_class.new(github_repo:, notify_jira: false)
        client = github_release_importer.send(:build_client)
        expect(client.access_token).to eq 'foobar'
      end
    end
  end
end
