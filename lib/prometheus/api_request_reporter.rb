module Prometheus
  class ApiRequestReporter
    def initialize(prometheus = Prometheus::Client.registry)
      @counter = prometheus.counter(:verify_frontend_api_request_total, docstring: "Number of API requests made", labels: [:method])
      @summary = prometheus.summary(:verify_frontend_api_request_duration, docstring: "Summary of API request durations", labels: [:method])
    end

    def report(_name, start, finish, _id, payload)
      @summary.observe(finish - start, labels: { method: payload[:method] })
      @counter.increment(labels: { method: payload[:method] })
    end
  end
end
