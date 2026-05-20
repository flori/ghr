require 'rails_helper'

describe ReposController, type: :controller do
  let :github_repo do
    GithubRepo.create(
      user: 'foo', repo: 'bar', tag_filter: "\\Av(\\d+.\\d+.\\d+)\\z"
    )
  end

  context 'json format' do
    describe "GET index" do
      it "renders the json response" do
        github_repo
        get :index
        expect(JSON(response.body)['repos'].first).to include('url' => 'http://test.host/repos/foo:bar/releases')
      end

      it "supports pagination" do
        github_repo
        _github_repo2 = GithubRepo.create(user: 'foo', repo: 'bar2', tag_filter: '.*')
        _github_repo3 = GithubRepo.create(user: 'foo', repo: 'bar3', tag_filter: '.*')

        get :index, params: { offset: 1, limit: 1 }

        json = JSON(response.body)
        expect(json['repos'].size).to eq 1
        expect(json['offset']).to eq 1
        expect(json['limit']).to eq 1
        expect(json['total']).to eq 3
      end
    end
  end
end
