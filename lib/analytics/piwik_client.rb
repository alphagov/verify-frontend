require 'pooling_client'

module Analytics
  class PiwikClient
    def initialize(piwik_url, options = {})
      @async = options.fetch(:async, true)
      @path = piwik_url.path
      @client = PoolingClient.new(piwik_url, {})
    end

    def report(params, headers = {})
      if async?
        Thread.new do
          do_report(params, headers)
        end
      else
        do_report(params, headers)
      end
    end

  private

    attr_reader :client

    def do_report(params, headers)
      begin
        client.get(@path, params: params, headers: headers)
      rescue HTTP::Error => e
        Rails.logger.error('Analytics reporting error: ' + e.message)
      end
    end

    def async?
      @async
    end
  end
end
