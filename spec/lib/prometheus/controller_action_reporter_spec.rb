require "spec_helper"
require "prometheus"
require "prometheus/controller_action_reporter"

module Prometheus
  describe ControllerActionReporter do
    let(:prometheus) { double(:prometheus_registry) }
    let(:total_summary) { double(:total_summary) }
    let(:view_summary) { double(:view_summary) }
    let(:reporter) { ControllerActionReporter.new(prometheus) }

    before(:each) do
      expect(prometheus).to receive(:summary)
                              .with(:verify_frontend_view_runtime, docstring: /render view/, labels: %i[controller action])
                              .and_return(view_summary)
      expect(prometheus).to receive(:summary)
                              .with(:verify_frontend_total_duration, docstring: /Total time/, labels: %i[controller action])
                              .and_return(total_summary)
    end

    it "should send total duration of event" do
      payload = { controller: "SomeController", action: "someAction" }
      duration = 0.060
      start = Time.now
      finish = start + duration
      allow(view_summary).to receive(:observe)
      expect(total_summary).to receive(:observe).with(duration, labels: { controller: "SomeController", action: "someAction" })
      reporter.report("event_name", start, finish, "notification_id", payload)
    end

    it "should send time spent rendering view" do
      view_runtime = 50.12
      payload = { controller: "AnotherController", action: "anotherAction", view_runtime: view_runtime }
      expect(view_summary).to receive(:observe).with(view_runtime / 1_000, labels: { controller: "AnotherController", action: "anotherAction" })
      allow(total_summary).to receive(:observe)
      reporter.report("event_name", Time.now, Time.now, "notification_id", payload)
    end

    it "should not send view rendering time if none is provided" do
      # Rails only sets view_runtime when rendering a view,
      # so it isn't set for redirects or AJAX responses.
      view_runtime = nil
      payload = { controller: "AnotherController", action: "anotherAction", view_runtime: view_runtime }
      allow(total_summary).to receive(:observe)
      expect(view_summary).not_to receive(:observe)
      expect(payload[:view_runtime]).to be_nil
      reporter.report("event_name", Time.now, Time.now, "notification_id", payload)
    end
  end
end
