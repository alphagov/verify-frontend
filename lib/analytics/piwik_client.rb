require 'http'

module Analytics
  class PiwikClient
    def initialize(ssl_context)
      @ssl_context = ssl_context
    end

    def report(params, headers = {})
      client(headers).get(PIWIK.url, params: params, ssl_context: @ssl_context)
    rescue HTTP::Error => e
      Rails.logger.error('Analytics reporting error: ' + e.message)
    end

  private

    def client(headers)
      HTTP.headers(headers)
    end
  end
end
