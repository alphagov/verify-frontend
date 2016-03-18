
module Analytics
  class Reporter
    def initialize(client, site_id)
      @client = client
      @site_id = site_id
    end

    def report(request, action_name)
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
      @client.report(piwik_params)
    end
  end
end
