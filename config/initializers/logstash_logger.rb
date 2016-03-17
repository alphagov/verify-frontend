LogStashLogger.configure do |config|
  config.customize_event do |event|
    event["SessionId"] = RequestStore.store[:session_id] || "no-current-session"
    event["level"] = event.remove "severity"
    event["service-name"] = "front"
  end
end
