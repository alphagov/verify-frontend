require 'uri'

class TestAnalyticsController < ApplicationController
  skip_before_action :validate_session

  def forward
    if PUBLIC_PIWIK.enabled? && INTERNAL_PIWIK.enabled?
      client = PoolingClient.new(INTERNAL_PIWIK.url, 'User-Agent' => request.user_agent)
      uri = INTERNAL_PIWIK.url
      uri.query = request.query_parameters.to_param
      begin
        client.get(uri)
      rescue HTTP::ConnectionError => e
        logger.error("Error connecting to analytics #{INTERNAL_PIWIK.url}: #{e}")
      end
    end
    head :ok
  end
end
