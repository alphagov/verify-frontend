require "prometheus"

if CONFIG.prometheus_enabled
  event_source = ActiveSupport::Notifications
  event_subscriber = Prometheus::EventSubscriber.new(event_source)

  controller_action_reporter = Prometheus::ControllerActionReporter.new
  event_subscriber.subscribe(/process_action.action_controller/, controller_action_reporter)

  api_request_reporter = Prometheus::ApiRequestReporter.new
  event_subscriber.subscribe(/api_request/, api_request_reporter)

  session_timeout_reporter = Prometheus::SessionTimeoutReporter.new
  event_subscriber.subscribe(/session_timeout/, session_timeout_reporter)
end
