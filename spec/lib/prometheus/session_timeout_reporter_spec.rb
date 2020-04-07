require "spec_helper"
require "prometheus"
require "prometheus/session_timeout_reporter"

module Prometheus
  describe SessionTimeoutReporter do
    let(:prometheus) { double(:prometheus_registry) }
    let(:counter) { double(:counter) }
    let(:summary) { double(:summary) }
    let(:reporter) { SessionTimeoutReporter.new(prometheus) }

    before(:each) do
      expect(prometheus).to receive(:counter)
                              .with(:verify_frontend_session_timeout_total, docstring: /Number of session timeouts/, labels: %i(service idp))
                              .and_return(counter)
      expect(prometheus).to receive(:summary)
                              .with(:verify_frontend_session_timeout_minutes_ago, docstring: /Ago minutes when the session expired/, labels: %i(service idp))
                              .and_return(summary)
    end

    it "should send total session timeouts" do
      minutes_ago = 10
      payload = { minutes_ago: minutes_ago, service: "test-rp", idp: "stub-idp" }
      expect(counter).to receive(:increment).with(labels: { service: "test-rp", idp: "stub-idp" })
      expect(summary).to receive(:observe).with(minutes_ago, labels: { service: "test-rp", idp: "stub-idp" })
      reporter.report("event_name", "start", "finish", "notification_id", payload)
    end
  end
end
