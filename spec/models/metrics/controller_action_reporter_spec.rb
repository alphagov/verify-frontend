require 'spec_helper'
require 'models/metrics/controller_action_reporter'

module Metrics
  describe ControllerActionReporter do
    let(:statsd) { double(:statsd) }
    let(:reporter) { ControllerActionReporter.new(statsd) }

    it 'should send total duration of event' do
      payload = {controller: 'SomeController', action: 'someAction'}
      duration = 60
      start = Time.now
      finish = start + duration
      expect(statsd).to receive(:send).with("SomeController.someAction.total_duration", duration * 1000)
      allow(statsd).to receive(:send)
      reporter.report('event_name', start, finish, 'notification_id', payload)
    end

    it 'should send time spent rendering view' do
      view_runtime = 50.12
      payload = {controller: 'AnotherController', action: 'anotherAction', view_runtime: view_runtime}
      allow(statsd).to receive(:send)
      expect(statsd).to receive(:send).with("AnotherController.anotherAction.view_runtime", view_runtime)
      reporter.report('event_name', Time.now, Time.now, 'notification_id', payload)
    end
  end
end
