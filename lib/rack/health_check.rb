module Rack
  class HealthCheck
    # Initializes a new instance with the given application object.
    #
    # @param app [ Object ] the application object to store as an instance variable
    def initialize(app)
      @app = app
    end

    # The call method handles health check requests and delegates to the
    # appropriate handler based on the request path.
    #
    # This method processes incoming HTTP requests and checks if they match any
    # of the predefined health check endpoints (readyz, livez, revisionz). For
    # these endpoints, it invokes the corresponding handler methods and returns
    # JSON responses with status information. If the request does not match any
    # health check endpoint, it delegates the request to the next middleware in
    # the chain.
    #
    # @param env [Hash] the Rack environment hash containing request details
    # @return [Array] a Rack response array consisting of status code, headers, and body
    def call(env)
      request_path = env['REQUEST_PATH']
      if request_path =~ %r'\A/(readyz|livez|revisionz)\z'
        begin
          response = send($1)
        rescue => e
          Rails.logger.warn("Caught #{e.class}: #{e}\n#{e.backtrace}")
          [ 503, { 'Content-Type' => 'application/json' }, [ JSON(status: 'nok') ] ]
        else
          [ 200, { 'Content-Type' => 'application/json' }, [ JSON(response) ] ]
        end
      else
        @app.call(env)
      end
    end

    private

    # Establishes a database connection for the current class and executes the
    # given block within that connection context.
    #
    # This method sets up a connection pool using ActiveRecord's connection
    # handler with the default environment, ensuring that the provided block is
    # executed within the context of this established connection. After the
    # block execution completes, it cleans up by removing the connection pool
    # associated with the class name.
    #
    # @param block [Proc] the block to execute within the database connection context
    # @return [Object] the return value of the executed block
    def with_connection(&block)
      default_env = ActiveRecord::ConnectionHandling::DEFAULT_ENV.call.to_sym
      pool = ActiveRecord::Base.connection_handler.establish_connection(default_env, owner_name: self.class.name)

      pool.with_connection(&block)
    ensure
      ActiveRecord::Base.connection_handler.remove_connection_pool(self.class.name)
    end

    # Indicates the liveness of the application by checking if the database
    # connection is established
    #
    # This method verifies that the ActiveRecord database connection is active
    # and functional by executing a simple query. It returns a JSON response
    # indicating whether the application is alive ('ok') or not ('nok').
    #
    # @return [Hash] a hash containing the status key with value 'ok' if
    # database connection is alive, 'nok' otherwise
    def livez
      { status: check_if_active_record_connection_alive ? 'ok' : 'nok' }
    end

    # Indicates the readiness of the application by checking the database
    # connection status
    #
    # This method verifies whether the ActiveRecord database connection is
    # established and returns a JSON response indicating the readiness status
    # as 'ok' if the connection is alive, or 'nok' if it is not
    #
    # @return [Hash] a hash containing the status key with value 'ok' or 'nok'
    def readyz
      { status: check_if_active_record_connection_alive ? 'ok' : 'nok' }
    end

    # Shows the revision of the application by returning a hash with the status
    # and revision information.
    #
    # This method checks for the presence of a revision identifier in the
    # application's configuration. If found, it returns a hash indicating the
    # status as 'ok' along with the revision value. If no revision is found, it
    # returns a hash indicating the status as 'nok' with the revision set to
    # 'n/a'.
    #
    # @return [Hash] a hash containing the revision and status keys
    # @example
    #   { revision: 'abc123d', status: 'ok' }
    #   { revision: 'n/a', status: 'nok' }
    def revisionz
      if revision = GhrConfig::REVISION?
        status = 'ok'
      else
        revision = 'n/a'
        status   = 'nok'
      end
      { revision:, status: }
    end

    # Checks if the Active Record database connection is alive and responsive
    #
    # This method verifies that the database connection is functional by
    # executing a simple query against the database. It returns true if the
    # connection is alive and the query succeeds, otherwise it returns false.
    #
    # @return [TrueClass, FalseClass] true if the database connection is alive,
    # false otherwise
    def check_if_active_record_connection_alive
      1 == with_connection { it.select_value(%{ SELECT 1 }) }
    end
  end
end
