require 'rails_helper'

RSpec.describe AllNewGithubReleasesImporter, type: :model do
  let :github_repo do
    GithubRepo.create(
      user: 'metabase',
      repo: 'metabase',
      tag_filter: '\Av(\d+\.\d+\.\d+)\z',
      configured_notifiers: %[ JIRA ],
    )
  end

  it 'can perform' do
    expect(GithubReleaseImporter).to receive(:new).with(github_repo: github_repo, notify: true).and_return(double(perform: 23))
    described_class.new.perform
  end

  it "won't import unless import_enabled" do
    github_repo.update(import_enabled: false)
    expect(GithubReleaseImporter).not_to receive(:new)
    described_class.new.perform
  end

  it 'can perform when there are no releases' do
    expect(GithubReleaseImporter).to receive(:new).with(github_repo: github_repo, notify: true).and_return(double(perform: nil))
    described_class.new.perform
  end

  it 'catches standard errors from GithubReleaseImporter and log them' do
    github_repo
    expect(GithubReleaseImporter).to receive(:new).and_raise StandardError
    expect(Rails.logger).to receive(:error).with('Error StandardError "StandardError" while importing releases for metabase:metabase.')
    expect(Rails.logger).to receive(:error).with(a_kind_of(StandardError))
    described_class.new.perform
  end
end

