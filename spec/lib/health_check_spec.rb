require 'rails_helper'

describe Rack::HealthCheck do
  let :app do
    double('App')
  end

  let :env do
    {
      'REQUEST_METHOD'  => 'GET',
    }
  end

  let :instance do
    described_class.new(app)
  end

  it 'ingores /otherz' do
    env['REQUEST_PATH']       = '/otherz'
    expect(app).to receive(:call).with(env).and_return :next
    status, headers, body = instance.call(env)
    expect(status).to eq :next
		expect(headers['Content-Type']).to eq 'application/json'
  end

  it 'handles /readyz' do
    env['REQUEST_PATH']       = '/readyz'
    expect(app).not_to receive(:call).with(env)
    status, headers, body = instance.call(env)
    expect(status).to eq 200
		expect(headers['Content-Type']).to eq 'application/json'
  end

  it 'handles /livez' do
    env['REQUEST_PATH']       = '/livez'
    expect(app).not_to receive(:call).with(env)
    status, headers, body = instance.call(env)
    expect(status).to eq 200
		expect(headers['Content-Type']).to eq 'application/json'
  end

  it 'handles /livez for unavailable active record database connection' do
    env['REQUEST_PATH']       = '/livez'
    expect(app).not_to receive(:call).with(env)
    expect(instance).to receive(:check_if_active_record_connection_alive).
      and_raise StandardError
    status, headers, body = instance.call(env)
    expect(status).to eq 503
		expect(headers['Content-Type']).to eq 'application/json'
  end
end
