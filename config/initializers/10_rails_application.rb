# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w(style.css style-ie8.css gov.uk_logotype_crown.svg)

# Set cookie serializer
Rails.application.config.action_dispatch.cookies_serializer = :json

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [:password]

# Set session cookie name
Rails.application.config.session_store :cookie_store, key: CookieNames::SESSION_COOKIE_NAME

# Enable parameter wrapping for JSON. You can disable this by setting :format to an empty array.
ActiveSupport.on_load(:action_controller) do
  wrap_parameters format: [:json] if respond_to?(:wrap_parameters)
end

# Add additional paths to load for I18n
Rails.application.config.i18n.load_path += Dir[File.join(CONFIG.rp_display_locales, '*.yml').to_s]
Rails.application.config.i18n.load_path += Dir[File.join(CONFIG.idp_display_locales, '*.yml').to_s]
Rails.application.config.i18n.load_path += Dir[File.join(CONFIG.cycle_3_display_locales, '*.yml').to_s]

# Middleware for providing service status
require 'service_status_filter'
Rails.application.config.middleware.use ServiceStatusFilter

# Middleware for storing the session ID
require 'store_session_id'
Rails.application.config.middleware.insert_before Rails::Rack::Logger, StoreSessionId
