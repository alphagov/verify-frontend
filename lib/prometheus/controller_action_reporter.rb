module Prometheus
  class ControllerActionReporter
    def initialize(prometheus = Prometheus::Client.registry)
      @view_runtime_summary = prometheus.summary(:verify_frontend_view_runtime, docstring: "Time taken to render view", labels: %i[controller action])
      @total_duration_summary = prometheus.summary(:verify_frontend_total_duration, docstring: "Total time taken to process controller action", labels: %i[controller action])
    end

    def report(_name, start, finish, _id, payload)
      @total_duration_summary.observe(finish - start, labels: { controller: payload[:controller], action: payload[:action] })
      view_runtime = payload[:view_runtime]
      @view_runtime_summary.observe(view_runtime / 1_000, labels: { controller: payload[:controller], action: payload[:action] }) unless view_runtime.nil?
    end
  end
end
