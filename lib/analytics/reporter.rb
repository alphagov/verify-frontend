
module Analytics
  class Reporter
    def initialize(client, site_id)
      @client = client
      @site_id = site_id
    end

    def report_custom_variable(request, action_name, custom_variable)
      report_to_piwik(request, action_name, '_cvar' => custom_variable.to_json)
    end

    def report_event(request, event_category, event_name, event_action)
      event = {
          e_c: event_category,
          e_n: event_name,
          e_a: event_action.to_s,
      }
      report_to_piwik(request, 'trackEvent', event)
    end

    def report(request, action_name)
      report_to_piwik(request, action_name)
    end

  private

    def report_to_piwik(request, action_name, additional_params = {})
      piwik_params = {
        'rec' => '1',
        'apiv' => '1',
        'idsite' => @site_id,
        'action_name' => action_name,
        'url' => request.url,
        'cdt' => Time.now.strftime('%Y-%m-%d %H:%M:%S'),
        'cookie' => 'false',
      }.merge(additional_params)

      cookies = request.cookies
      piwik_params['uid'] = cookies[CookieNames::PIWIK_USER_ID] if cookies.has_key? CookieNames::PIWIK_USER_ID
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
        'X-Forwarded-For' => headers['X-Forwarded-For'],
        'User-Agent' => headers['User-Agent'],
        'Accept-Language' => headers['Accept-Language']
      }
    end
  end
end
