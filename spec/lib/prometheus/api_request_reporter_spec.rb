require 'spec_helper'
require 'prometheus'
require 'prometheus/api_request_reporter'

module Prometheus
  describe ApiRequestReporter do
    let(:prometheus) { double(:prometheus_registry) }
    let(:counter) { double(:counter) }
    let(:summary) { double(:summary) }
    let(:reporter) { ApiRequestReporter.new(prometheus) }

    before(:each) do
      expect(prometheus).to receive(:counter)
                              .with(:verify_frontend_api_request_total, docstring: /Number of API requests/, labels: [:method])
                              .and_return(counter)
      expect(prometheus).to receive(:summary)
                              .with(:verify_frontend_api_request_duration, docstring: /API request duration/, labels: [:method])
                              .and_return(summary)
    end

    it 'should send total duration of event' do
      payload = { path: '/endpoint', method: 'get' }
      duration = 0.060
      start = Time.now
      finish = start + duration
      expect(counter).to receive(:increment).with(labels: { method: "get" })
      expect(summary).to receive(:observe).with(duration, labels: { method: "get" })
      reporter.report('event_name', start, finish, 'notification_id', payload)
    end
  end
end
