require 'rails_helper'

describe JIRAClient, type: :model do
  let :jira_client do
    double('JIRA::Client')
  end

  before do
    described_class.disconnect
    allow(JIRA::Client).to receive(:new).and_return jira_client
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
    expect(described_class.reconnect).to eq jira_client
  end

  it 'can find our main project' do
    project = double('Project')
    expect(project).to receive(:find).with(JIRAClient.complex_config.jira.project).and_return project
    expect(jira_client).to receive(:Project).and_return project
    expect(described_class.project).to eq project
  end

  it 'can register a new issue' do
    issue = double('Issue', build: double(save: true))
    expect(jira_client).to receive(:Issue).and_return issue
    described_class.issue!(summary: 'foo', description: 'bar')
  end
end
