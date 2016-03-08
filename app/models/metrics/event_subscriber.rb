module Metrics
  class EventSubscriber
    def initialize(event_source)
      @event_source = event_source
    end

    def report(filter, reporter)
      @event_source.subscribe filter do |*args|
        reporter.report(*args)
      end
    end
  end
end
