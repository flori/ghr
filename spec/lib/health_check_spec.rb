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

  it 'ignores /otherz' do
    env['PATH_INFO']       = '/otherz'
    expect(app).to receive(:call).with(env).and_return :next
    status, _headers, _body = instance.call(env)
    expect(status).to eq :next
  end

  it 'handles /readyz' do
    env['PATH_INFO']       = '/readyz'
    expect(app).not_to receive(:call).with(env)
    status, headers, body = instance.call(env)
    expect(status).to eq 200
    expect(headers['Content-Type']).to eq 'application/json'
    expect(JSON(body.first)['status']).to eq 'ok'
  end

  it 'handles /livez' do
    env['PATH_INFO']       = '/livez'
    expect(app).not_to receive(:call).with(env)
    status, headers, body = instance.call(env)
    expect(status).to eq 200
    expect(headers['Content-Type']).to eq 'application/json'
    expect(JSON(body.first)['status']).to eq 'ok'
  end

  it 'handles /livez for unavailable active record database connection' do
    env['PATH_INFO']       = '/livez'
    expect(app).not_to receive(:call).with(env)
    expect(instance).to receive(:check_if_active_record_connection_alive).
      and_raise StandardError
    status, headers, body = instance.call(env)
    expect(status).to eq 503
    expect(headers['Content-Type']).to eq 'application/json'
    expect(JSON(body.first)['status']).to eq 'nok'
  end

  it 'reports /revisionz if configured' do
    env['PATH_INFO']       = '/revisionz'
    const_conf_as('GhrConfig::REVISION'  => 'deadbee')
    expect(app).not_to receive(:call).with(env)
    status, headers, body = instance.call(env)
    expect(status).to eq 200
    expect(headers['Content-Type']).to eq 'application/json'
    data = JSON(body.first)
    expect(data['status']).to eq 'ok'
    expect(data['revision']).to eq 'deadbee'
  end

  it 'does not report /revisionz if not configured' do
    env['PATH_INFO']       = '/revisionz'
    const_conf_as('GhrConfig::REVISION'  => nil)
    expect(app).not_to receive(:call).with(env)
    status, headers, body = instance.call(env)
    expect(status).to eq 200
    expect(headers['Content-Type']).to eq 'application/json'
    data = JSON(body.first)
    expect(data['status']).to eq 'nok'
    expect(data['revision']).to eq 'n/a'
  end
end
