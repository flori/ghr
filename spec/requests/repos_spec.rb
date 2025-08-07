require 'rails_helper'

describe "Repos", type: :request do
  let :github_release do
    GithubRelease.new(
      url:          'https://foo.bar',
      html_url:     'https://foo.baz',
      name:         'The Evil',
      tag_name:     'v6.6.6',
      published_at: Time.now,
      body:         'test',
    )
  end

  before do
    github_repo = GithubRepo.create user: 'foo', repo: 'bar'
    github_repo.github_releases << github_release
  end

  describe "GET /repos" do
    it "returns http success" do
      get "/repos"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /repos/:id" do
    it "returns http success" do
      get "/repos/foo:bar"
      expect(response).to have_http_status(:success)
    end
  end
end
