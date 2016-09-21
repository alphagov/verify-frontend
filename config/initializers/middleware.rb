# Middleware for providing service status
require 'service_status_filter'
Rails.application.config.middleware.use ServiceStatusFilter

# Middleware for storing the session ID
require 'store_session_id'
Rails.application.config.middleware.insert_before Rails::Rack::Logger, StoreSessionId
