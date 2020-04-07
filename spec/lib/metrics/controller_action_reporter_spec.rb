require "spec_helper"
require "metrics"
require "metrics/controller_action_reporter"

module Metrics
  describe ControllerActionReporter do
    let(:statsd) { double(:statsd) }
    let(:reporter) { ControllerActionReporter.new(statsd) }

    it "should send total duration of event" do
      payload = { controller: "SomeController", action: "someAction" }
      duration = 0.060
      start = Time.now
      finish = start + duration
      expect(statsd).to receive(:timing).with("SomeController.someAction.total_duration", duration * 1_000)
      allow(statsd).to receive(:timing)
      reporter.report("event_name", start, finish, "notification_id", payload)
    end

    it "should send time spent rendering view" do
      view_runtime = 50.12
      payload = { controller: "AnotherController", action: "anotherAction", view_runtime: view_runtime }
      allow(statsd).to receive(:timing)
      expect(statsd).to receive(:timing).with("AnotherController.anotherAction.view_runtime", view_runtime)
      reporter.report("event_name", Time.now, Time.now, "notification_id", payload)
    end

    it "should not send view rendering time if none is provided" do
      # Rails only sets view_runtime when rendering a view,
      # so it isn't set for redirects or AJAX responses.
      view_runtime = nil
      payload = { controller: "AnotherController", action: "anotherAction", view_runtime: view_runtime }
      allow(statsd).to receive(:timing)
      expect(statsd).not_to receive(:timing).with("AnotherController.anotherAction.view_runtime", view_runtime)
      reporter.report("event_name", Time.now, Time.now, "notification_id", payload)
    end
  end
end
