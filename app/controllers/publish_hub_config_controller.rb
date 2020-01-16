class PublishHubConfigController < ApplicationController
  skip_before_action :validate_session
  skip_before_action :set_piwik_custom_variables
  skip_after_action :store_locale_in_cookie

  before_action :authorize

  rescue_from StandardError do |exception|
    render plain: exception, status: 500
  end

  def service_status
    do_not_cache
    response = publish_hub_config_client.healthcheck
    render plain: response.to_s, status: response.status
  end

  def certificates
    do_not_cache
    response = publish_hub_config_client.certificates(request.path.split('/hub/config/config/certificates/').last)
    render json: response.to_s, status: response.status
  end

private

  def authorize
    return head :unauthorized unless request.headers["X-Self-Service-Authentication"] == Rails.application.secrets.self_service_authentication_header
  end

  def do_not_cache
    response.headers['Cache-Control'] = 'no-cache, no-store, no-transform'
  end

  def publish_hub_config_client
    PUBLISH_HUB_CONFIG_CLIENT
  end
end
