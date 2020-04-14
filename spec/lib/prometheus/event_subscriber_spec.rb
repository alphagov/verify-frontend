require "spec_helper"
require "prometheus/event_subscriber"

module Prometheus
  describe EventSubscriber do
    let(:reporter) { double(:reporter) }
    let(:event_source) { double(:event_source) }

    it "should subscribe to specific events from an events source" do
      expect(event_source).to receive(:subscribe).with("filter")
      event_subscriber = EventSubscriber.new(event_source)
      event_subscriber.subscribe("filter", reporter)
    end
  end
end
