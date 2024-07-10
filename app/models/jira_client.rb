module JIRAClient
  module_function

  # @return [ComplexConfig::Settings] the current JIRA configuration.
  def config
    complex_config.jira
  end

  # Connect to JIRA API using the account configuration from the configuration
  #
  # @return [JIRA::Client]
  def connect
    @client ||=
      JIRA::Client.new(
        site: config.site,
        username: config.username,
        password: config.api_token,
        context_path: '',
        auth_type: :basic,
        read_timeout: 120
      )
  end

  # Returns true if all the configuration options are set, false otherwise.
  #
  # @return [Boolean]
  def configured?
    !!(
      config.site? && config.username? && config.api_token? &&
      config.project? && config.label?
    )
  end

  # Disconnect the currently connected client if any.
  def disconnect
    @client = nil
  end

  # @return [Boolean] whether the client is connected or not
  def connected?
    !!@client
  end

  # Reconnect with freshly created client.
  def reconnect
    disconnect
    connect
  end

  # @return the configured project to add issues to.
  def project
    connect.Project.find(config.project)
  end

  # Create an issue in JIRA using the given parameters and  configuration, then
  # return it.
  #
  # @param [String] summary for the issue
  # @param [String] description for the issue
  def issue!(summary:, description:)
    fields = {
      project: { key: config.project },
      labels: [ config.label ],
      issuetype: { id: 10007 }, # key is "Type"
      summary:,
      description:,
    }
    if name = config.component.full?
      fields |= { components: [ { name: } ] }
    end
    object = connect.Issue.build
    object.save(fields:)
    object
  end
end
