require 'rails_helper'

describe VersionFilter, type: :model do
  let :github_repo do
    GithubRepo.new user: 'metabase', repo: 'metabase', tag_filter: '\Av(.+)',
      version_requirement: %w[ <3 ~>1.2.1 ]
  end

  it 'can be passed github repos' do
    vf = described_class.for_github_repo(github_repo)
    expect(vf).not_to match 'foo'
    expect(vf).to match 'v1.2.3'
    expect(vf).not_to match 'v1.3.3'
    expect(vf).not_to match 'v3.3.3'
  end

  it 'can just filter tag names' do
    vf = described_class.new('\Av[\d.]+\z', [])
    expect(vf).not_to match 'foo'
    expect(vf).to match 'v1.2.3'
    # In this case doesn't need to be a valid version spec
    expect(vf).to match 'v1....3'
  end

  it 'can filter tag names with regexp' do
    vf = described_class.new(/\Av[\d.]+\z/, [])
    expect(vf).not_to match 'foo'
    expect(vf).to match 'v1.2.3'
  end

  it 'can filter tag names and satisfy version requirements' do
    vf = described_class.new('\Av(\d+)\.(\d+)\.(\d+)\z', %w[ <3 ~>1.2.1 ])
    expect(vf).not_to match 'foo'
    expect(vf).to match 'v1.2.3'
    expect(vf).not_to match 'v1.3.3'
    expect(vf).not_to match 'v3.3.3'
  end

  it 'can filter tag names and satisfy version requirements with . in groups' do
    vf = described_class.new('\Av([\d+.]+)\z', %w[ <3 ~>1.2.1 ])
    expect(vf).not_to match 'foo'
    expect(vf).to match 'v1.2.3'
    expect(vf).not_to match 'v1.3.3'
    expect(vf).not_to match 'v3.3.3'
  end

  it 'can filter tag names and satisfy version requirements with unusual tags' do
    vf = described_class.new('\Av(\d+)_(\d+)_(\d+)\z', %w[ <3 ~>1.2.1 ])
    expect(vf).not_to match 'foo'
    expect(vf).to match 'v1_2_3'
    expect(vf).not_to match 'v1_3_3'
    expect(vf).not_to match 'v3_3_3'
  end

  it 'can raise argument error if version match/group is invalid' do
    vf = described_class.new('\Av[\d.]+\z', %w[ <3 ~>1.2.1 ])
    expect { vf =~ 'v1....3' }.to raise_error ArgumentError
  end
end
