require 'rails_helper'

describe JIRAClient, type: :model do
  before do
    described_class.disconnect
    const_conf_as(
      'GhrConfig::JIRA::URL'       => 'http://test.atlassian.net:443/',
      'GhrConfig::JIRA::USERNAME'  => 'testuser',
      'GhrConfig::JIRA::API_TOKEN' => 'testpassword',
      'GhrConfig::JIRA::ENABLED'   => true,
    )
  end

  let :jira_client do
    described_class.connect
  end

  it 'can be configured' do
    expect(described_class).to be_configured
  end

  it 'has correct configuration' do
    expect(jira_client).to be_a JIRA::Client
    expect(jira_client.options[:site]).to eq 'http://test.atlassian.net:443/'
    expect(jira_client.options[:username]).to eq 'testuser'
    expect(jira_client.options[:password]).to eq 'testpassword'
  end

  it 'can connect' do
    expect do
      expect(described_class.connect).to eq jira_client
    end.to change { described_class.connected? }.from(false).to(true)
  end

  it 'can disconnect' do
    expect do
      expect(described_class.disconnect).to be_nil
    end.not_to change { described_class.connected? }.from(false)
    expect(described_class.connect).to eq jira_client
    expect do
      expect(described_class.disconnect).to be_nil
    end.to change { described_class.connected? }.from(true).to(false)
  end

  it 'can reconnect' do
    expect(described_class.connect).to eq jira_client
    expect(described_class).to receive(:disconnect).and_call_original
    new_jira_client = described_class.reconnect
    expect(new_jira_client).to be_a JIRA::Client
    expect(new_jira_client).not_to eq jira_client
  end

  it 'can find our main project' do
    const_conf_as('GhrConfig::JIRA::PROJECT' => 'FOO')
    project = double('Project')
    expect(project).to receive(:find).with('FOO').and_return project
    expect(jira_client).to receive(:Project).and_return project
    expect(described_class.project).to eq project
  end

  it 'can register a new issue' do
    issue = double('Issue', build: double(save: true))
    expect(jira_client).to receive(:Issue).and_return issue
    described_class.issue!(summary: 'foo', description: 'bar')
  end
end
