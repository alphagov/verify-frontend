require "store_session_id"
Rails.application.config.middleware.insert_before Rails::Rack::Logger, StoreSessionId
