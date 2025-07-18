require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

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

    # Specifies whether `to_time` methods preserve the UTC offset of their receivers or preserves the timezone.
    # If set to `:zone`, `to_time` methods will use the timezone of their receivers.
    # If set to `:offset`, `to_time` methods will use the UTC offset.
    # If `false`, `to_time` methods will convert to the local system UTC offset instead.
    config.active_support.to_time_preserves_timezone = :zone

    config.active_record.query_log_tags_enabled = true
    config.active_record.query_log_tags_format = :sqlcommenter
    config.active_record.query_log_tags = [ :application, :controller, :action, :job ]

    ENV['GHR_HOST'].full? { config.hosts << _1 }

    if url = ENV['EMAIL_NOTIFY_SMTP_URL'].full? { URI.parse(it) }
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
