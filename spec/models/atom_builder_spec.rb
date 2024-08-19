require 'rails_helper'

RSpec.describe AtomBuilder, type: :model do
  let :github_repo do
    GithubRepo.create user: 'metabase', repo: 'metabase'
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

  before do
    stub_request(:get, "https://api.github.com/repos/metabase/metabase").
      with(headers: {
        'Accept'=>'application/vnd.github.v3+json',
        'Content-Type'=>'application/json',
      }).
      to_return(status: 200, body: read_fixture('repos.json'), headers: { 'Content-Type' => 'application/json' })
  end

  let :instance do
    described_class.new(github_repo.github_releases, host: 'foo.com')
  end

  it 'can build an empty feed' do
    expect(instance.to_atom).to eq "<feed xmlns='http://www.w3.org/2005/Atom'/>"
  end

  it 'can build a feed with releases' do
    github_release.github_repo = github_repo
    github_release.save!
    github_repo.reload
    expect(instance.to_atom).to eq(
      "<feed xmlns='http://www.w3.org/2005/Atom'><id>https://api.github.com/repos/metabase/metabase</id><title type='text'>Github Releases of metabase:metabase</title><updated>2011-11-11T11:11:11Z</updated><link href='http://foo.com/repos/metabase:metabase' rel='self'/><author><name>metabase</name></author><entry><id>https://foo.bar</id><title type='text'>The Evil (v6.6.6)</title><content type='html'>&lt;p&gt;test&lt;/p&gt;\n</content><updated>2011-11-11T11:11:11Z</updated><link href='https://foo.baz' rel='alternate'/></entry></feed>"
    )
  end

  it 'can build a feed with a a release and body nil' do
    github_release.github_repo = github_repo
    github_release.body = nil
    github_release.save!
    github_repo.reload
    expect(instance.to_atom).to eq(
      "<feed xmlns='http://www.w3.org/2005/Atom'><id>https://api.github.com/repos/metabase/metabase</id><title type='text'>Github Releases of metabase:metabase</title><updated>2011-11-11T11:11:11Z</updated><link href='http://foo.com/repos/metabase:metabase' rel='self'/><author><name>metabase</name></author><entry><id>https://foo.bar</id><title type='text'>The Evil (v6.6.6)</title><content type='html'>\n</content><updated>2011-11-11T11:11:11Z</updated><link href='https://foo.baz' rel='alternate'/></entry></feed>"
    )
  end
end
