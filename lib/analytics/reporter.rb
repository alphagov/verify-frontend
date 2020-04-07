module Analytics
  class Reporter
    def initialize(client, site_id)
      @client = client
      @site_id = site_id
    end

    def report_event(request, custom_variables, event_category, event_name, event_action)
      event = {
          "e_c" => event_category,
          "e_n" => event_name,
          "e_a" => event_action.to_s,
      }
      report_action(request, "trackEvent", custom_variables, event)
    end

    def report_action(request, action_name, custom_variables, event_params = {})
      piwik_params = {
        "rec" => "1",
        "apiv" => "1",
        "idsite" => @site_id,
        "action_name" => action_name,
        "url" => request.url,
        "cdt" => Time.now.strftime("%Y-%m-%d %H:%M:%S"),
        "cookie" => "false",
        "_cvar" => custom_variables.to_json,
      }.merge(event_params)

      cookies = request.cookies
      piwik_params["uid"] = cookies[CookieNames::PIWIK_USER_ID] if cookies.has_key? CookieNames::PIWIK_USER_ID
      referer = request.referer
      unless referer.nil?
        piwik_params["urlref"] = referer
        piwik_params["ref"] = referer
      end
      @client.report(piwik_params, headers(request))
    end

  private

    def headers(request)
      headers = request.headers
      {
        "X-Forwarded-For" => headers["X-Forwarded-For"],
        "User-Agent" => headers["User-Agent"],
        "Accept-Language" => headers["Accept-Language"],
      }
    end
  end
end
