class HealthcheckController < ApplicationController
  # Indicates the readiness of the application by returning a JSON response
  # with the status of "ok" if the database connection is established,
  # otherwise an error is returned.
  def readyz
    ActiveRecord::Base.connection.select_one(%{ SELECT 1 })
    render json: { status: 'ok' }
  end

  # Indicates the liveness of the application by returning a JSON response with
  # the status of "ok" if the database connection is established, otherwise an
  # error is returned.
  def livez
    ActiveRecord::Base.connection.select_one(%{ SELECT 1 })
    render json: { status: 'ok' }
  end

  # Shows the revision of the application by returning a JSON response with the
  # status of "ok" if it was found in the environment variables REVISION and
  # displaying it with the name +revision+, otherwise status will be "nok".
  def revisionz
    if revision = ENV['REVISION'].presence
      status = 'ok'
    else
      revision = 'n/a'
      status   = 'nok'
    end
    render json: { revision:, status: }
  end
end
