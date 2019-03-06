module Prometheus
  class EventSubscriber
    def initialize(event_source)
      @event_source = event_source
    end

    def subscribe(filter, reporter)
      @event_source.subscribe filter do |*args|
        reporter.report(*args)
      end
    end
  end
end
