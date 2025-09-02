Dir["#{Rails.root.join('lib/rack')}/*.rb"].each { |f| require f }

Ghr::Application.configure do
  config.middleware.insert_before 0, ::Rack::HealthCheck
end
