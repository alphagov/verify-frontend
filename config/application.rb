# coding: utf-8

require File.expand_path('../boot', __FILE__)

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
# require "active_record/railtie"
require "action_controller/railtie"
#require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.


Bundler.require(*Rails.groups)


module VerifyFrontend
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en

    config.exceptions_app = self.routes

    # Add recommended security headers and apply a basic lenient Content Security Policy
    config.action_dispatch.default_headers = {
      'X-Frame-Options' => 'DENY',
      'X-XSS-Protection' => '1; mode=block',
      'X-Content-Type-Options' => 'nosniff',
      'Content-Security-Policy' => "default-src 'self'; " +
        "font-src data:; " +
        "img-src 'self'; " +
        "object-src 'none'; " +
        # the script digests are for the two inline scripts in govuk_template.gem:govuk_template.html.erb
        # if the scripts in that file change, or more are added, use a command similar to
        # this to generate the digests:
        # `echo "'sha256-"$(echo -n "inline javascript text" | openssl dgst -sha256 -binary | openssl enc -base64)"'"`
        "script-src 'self' 'unsafe-eval' 'sha256-+6WnXIl4mbFTCARd8N3COQmT3bJJmo32N8q8ZSQAIcU=' 'sha256-G29/qSW/JHHANtFhlrZVDZW1HOkCDRc78ggbqwwIJ2g=' 'unsafe-inline'; " +
        "style-src 'self' 'unsafe-inline'"
    }
    RouteTranslator.config do |config|
      config.hide_locale = true
      config.available_locales = %i[en cy]
    end

    # by default rails wraps invalid inputs with <div class="field_with_errors">
    # we have our own way of styling errors, so we don't need this behaviour:
    config.action_view.field_error_proc = Proc.new { |html_tag| html_tag }

    # Rails 5 automatically disables submit buttons after they’ve bee clicked on once.
    # If you go back on our pages it remembers the disabled state, thus breaking the system.
    # We can turn this functionality off globally.
    config.action_view.automatically_disable_submit_tag = false

    raise "Missing secret_key_base. Please make sure config/secrets.yml is valid." if Rails.application.secrets.secret_key_base.nil?
  end
end
