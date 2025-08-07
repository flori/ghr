require 'rails_helper'

describe GithubClient, type: :model do
  let :gitub_client do
    double('Octokit::Client', 'auto_paginate=': true)
  end

  before do
    described_class.disconnect
    allow(Octokit::Client).to receive(:new).and_return gitub_client
  end

  it 'can connect' do
    expect do
      expect(described_class.connect).to eq gitub_client
    end.to change { described_class.connected? }.from(false).to(true)
  end

  it 'can disconnect' do
    expect do
      expect(described_class.disconnect).to be_nil
    end.not_to change { described_class.connected? }.from(false)
    expect(described_class.connect).to eq gitub_client
    expect do
      expect(described_class.disconnect).to be_nil
    end.to change { described_class.connected? }.from(true).to(false)
  end
end

