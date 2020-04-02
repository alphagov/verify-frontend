module Prometheus
  class SessionTimeoutReporter
    def initialize(prometheus = Prometheus::Client.registry)
      @counter = prometheus.counter(:verify_frontend_session_timeout_total, docstring: "Number of session timeouts", labels: %i(service idp))
      @summary = prometheus.summary(:verify_frontend_session_timeout_minutes_ago, docstring: "Ago minutes when the session expired", labels: %i(service idp))
    end

    def report(_name, _start, _finish, _id, payload)
      @summary.observe(payload[:minutes_ago], labels: { service: payload[:service], idp: payload[:idp] })
      @counter.increment(labels: { service: payload[:service], idp: payload[:idp] })
    end
  end
end
