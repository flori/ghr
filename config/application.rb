require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Setup GhrConfig configuration.
require_relative 'ghr_config.rb'

module Ghr
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # Enable query logging with tags
    config.active_record.query_log_tags_enabled = true

    # # Set the format for query log tags to SQL comment style
    config.active_record.query_log_tags_format = :sqlcommenter

    # Specify which tags to include in query logs (application, controller,
    # action, job) These tags help identify the source and context of database
    # queries for debugging and monitoring
    config.active_record.query_log_tags = [ :application, :controller, :action, :job ]

    # Disables ActiveStorage's automatic image variant processing
    config.active_storage.variant_processor = :disabled

    # Set up a whitelist of allowed hostnames to prevent HTTP Host header
    # injection attacks by validating that incoming requests come from trusted
    # domains.
    if hosts = GhrConfig::HOSTS_ALLOWED?
      STDOUT.puts "Configuring hosts allowed: #{hosts * ', '}"
      hosts.each { config.hosts << it }
    end

    if url = GhrConfig::EMAIL::NOTIFY_SMTP_URL?
      # Specify outgoing SMTP server. Remember to add smtp/* credentials via rails credentials:edit.
      config.action_mailer.smtp_settings = {
        user_name: url.user,
        password: url.password,
        address: url.host,
        port: url.port,
        authentication: :plain,
        enable_starttls_auto: true,
      }
    end
  end
end
