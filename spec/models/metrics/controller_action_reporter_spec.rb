require 'spec_helper'
require 'models/metrics/controller_action_reporter'

module Metrics
  describe ControllerActionReporter do
    let(:graphite) { double(:graphite) }
    let(:reporter) { ControllerActionReporter.new(graphite) }

    it 'should send a duration of 60 when start and finish 60s apart' do
      payload = {controller: 'SomeController', action: 'someAction'}
      duration = 60
      start = Time.now
      finish = start + duration
      expect(graphite).to receive(:send).with("SomeController.someAction.total_duration", duration)
      reporter.report('event_name', start, finish, 'notification_id', payload)
    end

    it 'should send a key constructed from the controller and action name' do
      payload = {controller: 'AnotherController', action: 'anotherAction'}
      duration = 60
      start = Time.now
      finish = start + duration
      expect(graphite).to receive(:send).with("AnotherController.anotherAction.total_duration", duration)
      reporter.report('event_name', start, finish, 'notification_id', payload)
    end
  end
end
