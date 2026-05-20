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
        expect(JSON(response.body).first).to include('url' => 'http://test.host/repos/foo:bar/releases')
      end
    end
  end
end
