
module Analytics
  class Reporter
    def initialize(client, site_id, originating_ip_store)
      @client = client
      @site_id = site_id
      @originating_ip_store = originating_ip_store
    end

    def report_custom_variable(request, action_name, custom_variable)
      report_to_piwik(request, action_name, custom_variable)
    end

    def report(request, action_name)
      report_to_piwik(request, action_name)
    end

    def report_to_piwik(request, action_name, custom_variable = nil)
      piwik_params = {
        'rec' => '1',
        'apiv' => '1',
        'idsite' => @site_id,
        'action_name' => action_name,
        'url' => request.url,
        'cdt' => Time.now.strftime('%Y-%m-%d %H:%M:%S'),
        'cookie' => 'false',
      }

      cookies = request.cookies
      piwik_params['_id'] = cookies[CookieNames::PIWIK_VISITOR_ID] if cookies.has_key? CookieNames::PIWIK_VISITOR_ID
      piwik_params['_cvar'] = custom_variable.to_json unless custom_variable.nil?
      referer = request.referer
      unless referer.nil?
        piwik_params['urlref'] = referer
        piwik_params['ref'] = referer
      end
      @client.report(piwik_params, headers(request))
    end

    def headers(request)
      headers = request.headers
      {
        'X-Forwarded-For' => originating_ip,
        'User-Agent' => headers['User-Agent'],
        'Accept-Language' => headers['Accept-Language']
      }
    end

  private

    def originating_ip
      @originating_ip_store.get
    end
  end
end
