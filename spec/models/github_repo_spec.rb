require 'rails_helper'

RSpec.describe GithubRepo, type: :model do
  context 'Creating and Finding' do
    it 'can be created' do
      repo = GithubRepo.create user: 'foo', repo: 'bar'
      expect(repo.user).to eq 'foo'
      expect(repo.repo).to eq 'bar'
    end

    it 'is unique in scope user' do
      repo = GithubRepo.create user: 'foo', repo: 'bar'
      repo = GithubRepo.create user: 'foo', repo: 'bar'
      expect(repo).to have(1).error_on(:repo)
    end

    it 'can be found by param' do
      repo = GithubRepo.create user: 'foo', repo: 'bar'
      repo = GithubRepo.find_by_param repo.to_param
      expect(repo.user).to eq 'foo'
      expect(repo.repo).to eq 'bar'
    end
  end

  context 'Adding' do
    it 'can be added with a tag_filter' do
      allow(GithubReleaseImporter).to receive(:new).
        and_return double('GithubReleaseImporter', perform: true)
      repo = GithubRepo.add(
        user: 'foo',
        repo: 'bar',
        tag_filter: tf = '\Av(0)\.(\d+)\.(\d+)\z',
        version_requirement: %w[ ~>0.44' ]
      )
      expect(repo).to be_a GithubRepo
      expect(repo.user).to eq 'foo'
      expect(repo.repo).to eq 'bar'
      expect(repo.tag_filter).to eq tf
      expect(repo).to be_import_enabled
      expect(repo).to be_jira_enabled
    end

    it 'triggers importing of releases w/o notifying jira initially' do
      github_release_importer = double('GithubReleaseImporter', perform: true)
      expect(GithubReleaseImporter).to receive(:new).with(
        github_repo: kind_of(GithubRepo),
        notify_jira: false
      ).and_return github_release_importer
      repo = GithubRepo.add(
        user: 'metabase',
        repo: 'metabase',
        tag_filter: tf = '\Av(0)\.(4\d+)\.(\d+)\z',
        version_requirement: %w[ ~>0.44' ]
      )
    end
  end
end
