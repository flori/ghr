require 'rails_helper'

RSpec.describe TagFilter, type: :model do
  it 'can match' do
    expect(described_class.new('\A[\d.]+\z').match('1.2.3')).to be_a MatchData
  end

  it 'can fail to match' do
    expect(described_class.new('\A[\d.]+\z').match('not-a-1.2.3')).to be_nil
  end

  it 'can return nil if not matching' do
    expect(described_class.new('\A[\d.]+\z').version('not-a-1.2.3')).to eq nil
  end

  it 'can return version objects' do
    expect(described_class.new('\A[\d.]+\z').version('1.2.3')).to be_a Tins::StringVersion::Version
  end

  it 'has the correct string version' do
    expect(described_class.new('\A[\d.]+\z').version('1.2.3')).to eq Tins::StringVersion('1.2.3')
  end
end
