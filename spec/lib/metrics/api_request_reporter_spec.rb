require 'spec_helper'
require 'metrics'
require 'metrics/api_request_reporter'

module Metrics
  describe ApiRequestReporter do
    let(:statsd) { double(:statsd) }
    let(:reporter) { ApiRequestReporter.new(statsd) }

    it 'should send total duration of event' do
      payload = { path: '/endpoint', method: 'get' }
      duration = 0.060
      start = Time.now
      finish = start + duration
      expect(statsd).to receive(:timing).with("Api.request.get.total_duration", duration * 1_000)
      expect(statsd).to receive(:increment).with("Api.request.get.count")
      reporter.report('event_name', start, finish, 'notification_id', payload)
    end
  end
end
