# Be sure to restart your server when you modify this file.
require "cookie_names"

Rails.application.config.session_store :cookie_store, key: CookieNames::SESSION_COOKIE_NAME
