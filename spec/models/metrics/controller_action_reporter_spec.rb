require 'spec_helper'
require 'models/metrics/controller_action_reporter'

module Metrics
  describe ControllerActionReporter do
    let(:graphite) { double(:graphite) }
    let(:reporter) { ControllerActionReporter.new(graphite) }

    it 'should send total duration of event' do
      payload = {controller: 'SomeController', action: 'someAction'}
      duration = 60
      start = Time.now
      finish = start + duration
      expect(graphite).to receive(:send).with("SomeController.someAction.total_duration_ms", duration * 1000)
      allow(graphite).to receive(:send)
      reporter.report('event_name', start, finish, 'notification_id', payload)
    end

    it 'should send time spent rendering view' do
      view_runtime_in_ms = 50.12
      payload = {controller: 'AnotherController', action: 'anotherAction', view_runtime: view_runtime_in_ms}
      allow(graphite).to receive(:send)
      expect(graphite).to receive(:send).with("AnotherController.anotherAction.view_runtime_ms", view_runtime_in_ms)
      reporter.report('event_name', Time.now, Time.now, 'notification_id', payload)
    end
  end
end
