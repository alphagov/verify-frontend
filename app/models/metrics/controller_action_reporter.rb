module Metrics
  class ControllerActionReporter
    KEY_DELIMETER = '.'

    def initialize(graphite)
      @graphite = graphite
    end

    def report(_name, start, finish, _id, payload)
      # args name and id get passed from ActiveSupport, however we will not need them to report.
      source = [payload[:controller], payload[:action]]
      @graphite.send(metric_key(source, 'total_duration'), finish - start)
    end

  private

    def metric_key(source, metric)
      [source, metric].join(KEY_DELIMETER)
    end
  end
end
