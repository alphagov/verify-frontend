module Metrics
  class ControllerActionReporter
    KEY_DELIMITER = '.'
    TOTAL_DURATION_IN_MS = 'total_duration_ms'
    VIEW_RUNTIME_IN_MS = 'view_runtime_ms'

    def initialize(graphite)
      @graphite = graphite
    end

    def report(_name, start, finish, _id, payload)
      # args name and id get passed from ActiveSupport, however we will not need them to report.
      source = [payload[:controller], payload[:action]]
      # Time.to_i converts to seconds and we want milliseconds
      @graphite.send(metric_key(source, TOTAL_DURATION_IN_MS), duration_in_ms(finish, start))
      @graphite.send(metric_key(source, VIEW_RUNTIME_IN_MS), payload[:view_runtime])
    end

  private

    def duration_in_ms(finish, start)
      (finish.to_i - start.to_i) * 1000
    end

    def metric_key(source, metric)
      [source, metric].join(KEY_DELIMITER)
    end
  end
end
