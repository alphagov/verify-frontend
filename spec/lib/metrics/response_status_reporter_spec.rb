require "spec_helper"
require "metrics/response_status_reporter"

module Metrics
  describe ResponseStatusReporter do
    let(:statsd) { double(:statsd) }
    let(:logger) { double(:logger) }
    let(:reporter) { ResponseStatusReporter.new(statsd, logger) }

    it "should report 1xx responses as 1xx_responses" do
      payload = { status: 110 }
      expect(statsd).to receive(:increment).with("1xx_responses")
      reporter.report("event_name", Time.now, Time.now, "notification_id", payload)
    end

    it "should report 2xx responses as 2xx_responses" do
      payload = { status: 200 }
      expect(statsd).to receive(:increment).with("2xx_responses")
      reporter.report("event_name", Time.now, Time.now, "notification_id", payload)
    end

    it "should report 3xx responses as 3xx_responses" do
      payload = { status: 303 }
      expect(statsd).to receive(:increment).with("3xx_responses")
      reporter.report("event_name", Time.now, Time.now, "notification_id", payload)
    end

    it "should report 4xx responses as 4xx_responses" do
      payload = { status: 404 }
      expect(statsd).to receive(:increment).with("4xx_responses")
      reporter.report("event_name", Time.now, Time.now, "notification_id", payload)
    end

    it "should report 5xx responses as 5xx_responses" do
      payload = { status: 505 }
      expect(statsd).to receive(:increment).with("5xx_responses")
      reporter.report("event_name", Time.now, Time.now, "notification_id", payload)
    end

    it "should not report the status code for responses missing code" do
      payload = {}
      expect(statsd).to_not receive(:increment)
      expect(logger).to receive(:warn).with("unable to read status code from response")
      reporter.report("event_name", Time.now, Time.now, "notification_id", payload)
    end

    it "should not report the status code for /service-status" do
      payload = { path: "/service-status", status: 200 }
      expect(statsd).to_not receive(:increment)
      reporter.report("event_name", Time.now, Time.now, "notification_id", payload)
    end
  end
end
