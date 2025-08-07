require 'rails_helper'

describe HealthcheckController, type: :controller do
  describe "GET readyz" do
    it "renders the json response" do
      get :readyz
      expect(JSON(response.body)).to include('status' => 'ok')
    end
  end

  describe "GET livez" do
    it "renders the json response" do
      get :livez
      expect(JSON(response.body)).to include('status' => 'ok')
    end
  end

  describe "GET revisionz" do
    it "renders the json response" do
      old, ENV['REVISION'] = ENV['REVISION'], nil
      get :revisionz
      expect(JSON(response.body)).to include('status' => 'nok')
      ENV['REVISION'] = 'fakerevision'
      get :revisionz
      expect(JSON(response.body)).to include('status' => 'ok')
    ensure
      ENV['REVISION'] = old
    end
  end
end
