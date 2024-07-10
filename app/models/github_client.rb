module GithubClient
  module_function

  # Connect to GitHub API using personal access token contained in environment
  # variable +GHR_GITHUB_PERSONAL_ACCESS_TOKEN+ (if given) and enable
  # auto-pagination.
  # @return [Octokit::Client]
  def connect
    @client ||= Octokit::Client.new(
      **{access_token: ENV['GHR_GITHUB_PERSONAL_ACCESS_TOKEN']}.compact
    )
    @client.auto_paginate = true
    @client
  end

  # Disconnect the currently connected client if any.
  def disconnect
    @client = nil
  end

  # @return [Boolean] whether the client is connected or not
  def connected?
    !!@client
  end
end
