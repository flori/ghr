require 'rails_helper'

RSpec.describe ReposController, type: :controller do
  let :github_repo do
    GithubRepo.create user: 'foo', repo: 'bar'
  end

  let :github_release do
    GithubRelease.new(
      url:          'https://foo.bar',
      html_url:     'https://foo.baz',
      name:         'The Evil',
      tag_name:     'v6.6.6',
      published_at: Time.parse('2011-11-11T11:11:11Z'),
      body:         'test',
    )
  end

  context 'json format' do
    describe "GET index" do
      it "renders the json response" do
        github_repo
        get :index
        expect(JSON(response.body).first).to include('url' => 'http://test.host/repos/foo:bar')
      end
    end

    describe "GET show" do
      it "renders the json response" do
        github_release.github_repo = github_repo
        github_release.save!
        get :show, params: { id: 'foo:bar' }
        expect(JSON(response.body).first).to include('url' => 'https://foo.bar')
      end

      it "returns not found if repo doesn't exist" do
        get :show, params: { id: 'foo:bar' }
        expect(response.status).to eq 404
      end
    end
  end

  context 'atom format' do
    describe "GET show" do
      it "returns not found if github has no releases" do
        github_repo
        get :show, params: { id: 'foo:bar' }, format: :atom
        expect(response.status).to eq 404
      end

      it "renders feed" do
        expect_any_instance_of(AtomBuilder).to receive(:repo_url).and_return 'https://repo.com/foo'
        github_repo
        github_release.github_repo = github_repo
        github_release.save!
        get :show, params: { id: 'foo:bar' }, format: :atom
        expect(response.body).to include("><id>https://repo.com/foo</id>")
      end
    end
  end
end

