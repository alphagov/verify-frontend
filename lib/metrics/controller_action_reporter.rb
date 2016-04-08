module Metrics
  class ControllerActionReporter
    def initialize(statsd_client)
      @statsd_client = statsd_client
    end

    def report(_name, start, finish, _id, payload)
      # args name and id get passed from ActiveSupport, however we will not need them to report.
      source = [payload[:controller], payload[:action]]
      @statsd_client.timing(Metrics::metric_key(source, TOTAL_DURATION), Metrics::duration(finish, start))
      view_runtime = payload[:view_runtime]
      @statsd_client.timing(Metrics::metric_key(source, VIEW_RUNTIME), view_runtime) unless view_runtime.nil?
    end
  end
end
