# Module for interacting with the GitHub API.
#
# This module provides functionality to connect to GitHub using a personal
# access token, manage the client connection, and handle auto-pagination of API
# responses. It ensures that only one client instance is created and reused
# throughout the application lifecycle.
#
# @example
#   # Connect to GitHub
#   client = GithubClient.connect
#
#   # Check if client is connected
#   connected = GithubClient.connected?
#
#   # Disconnect the client
#   GithubClient.disconnect
module GithubClient
  module_function

  # Connect to GitHub API using personal access token contained in environment
  # variable +GHR_GITHUB_PERSONAL_ACCESS_TOKEN+ (if given) and enable
  # auto-pagination.
  # @return [Octokit::Client]
  def connect
    @client ||= Octokit::Client.new(
      **{access_token: GhrConfig::GITHUB_PERSONAL_ACCESS_TOKEN}.compact
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
