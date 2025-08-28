module JIRAClient
  include ComplexConfig::Provider::Shortcuts
  extend ComplexConfig::Provider::Shortcuts

  module_function

  # Connects to the JIRA API and returns the client instance.
  #
  # This method establishes a connection to the JIRA service using configuration
  # values for the site URL, username, and API token. It ensures that only one
  # client instance is created and reused throughout the application lifecycle.
  #
  # @return [JIRA::Client] the connected JIRA client instance
  def connect
    @client ||=
      JIRA::Client.new(
        site:         GhrConfig::JIRA::URL,
        username:     GhrConfig::JIRA::USERNAME,
        password:     GhrConfig::JIRA::API_TOKEN,
        context_path: '',
        auth_type:    :basic,
        read_timeout: 120
      )
  end

  # Checks whether JIRA integration is enabled.
  #
  # @return [ TrueClass, FalseClass ] true if JIRA is enabled, false otherwise
  def configured?
    !!GhrConfig::JIRA::ENABLED?
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
    connect.Project.find(GhrConfig::JIRA::PROJECT)
  end

  # Create an issue in JIRA using the given parameters and  configuration, then
  # return it.
  #
  # @param [String] summary for the issue
  # @param [String] description for the issue
  def issue!(summary:, description:)
    fields = {
      project: { key: GhrConfig::JIRA::PROJECT },
      labels: GhrConfig::JIRA::LABELS,
      issuetype: { id: 10007 }, # key is "Type"
      summary:,
      description:,
    }
    if name = GhrConfig::JIRA::COMPONENT?
      fields |= { components: [ { name: } ] }
    end
    object = connect.Issue.build
    object.save(fields:)
    object
  end
end
