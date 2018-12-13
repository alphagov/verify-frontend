module UserCookiesPartialController
  def set_secure_cookie(name, value)
    cookies[name] = {
        value: value,
        httponly: true,
        secure: Rails.configuration.x.cookies.secure
    }
  end

  def set_visitor_cookie
    cookies[CookieNames::PIWIK_USER_ID] = SecureRandom.hex(8) unless cookies.has_key? CookieNames::PIWIK_USER_ID
  end

  def store_locale_in_cookie
    cookies.signed[CookieNames::VERIFY_LOCALE] = {
        value: I18n.locale,
        httponly: true,
        secure: Rails.configuration.x.cookies.secure
    }
  end

  def set_attempt_journey_hint(idp_entity_id)
    journey_hint_value_hash = journey_hint_value || {}
    journey_hint_value_hash['ATTEMPT'] = idp_entity_id

    cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = { value: journey_hint_value_hash.to_json,
                                                                  expires: 18.months.from_now }
  end

  def set_journey_hint_by_status(idp_entity_id, status, rp_entity_id = nil)
    return if idp_entity_id.nil?

    journey_hint_by_status_value = journey_hint_value || {}
    journey_hint_by_status_value = eat_journey_hint_cookie(journey_hint_by_status_value) unless journey_hint_by_status_value.empty?
    journey_hint_by_status_value['SUCCESS'] = idp_entity_id if status == 'SUCCESS'
    journey_hint_by_status_value['STATE'] = { IDP: idp_entity_id,
                                              RP: rp_entity_id.nil? ? session[:transaction_entity_id] : rp_entity_id,
                                              STATUS: status }

    cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = { value: journey_hint_by_status_value.to_json, expires: 18.months.from_now }
  end

  def set_resume_link_journey_hint(idp_simple_id)
    journey_hint_value_hash = journey_hint_value || {}
    journey_hint_value_hash['RESUMELINK'] = {
      IDP: idp_simple_id
    }

    cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = { value: journey_hint_value_hash.to_json,
                                                                  expires: 18.months.from_now }
  end

  def remove_resume_link_journey_hint
    journey_hint_value_hash = journey_hint_value || {}
    journey_hint_value_hash.delete('RESUMELINK')

    cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = { value: journey_hint_value_hash.to_json,
                                                                  expires: 18.months.from_now }
  end

  def set_single_idp_journey_cookie(data)
    cookies.encrypted[CookieNames::VERIFY_SINGLE_IDP_JOURNEY] = {
      value: data.to_json,
      expires: 90.minutes.from_now
    }
  end

private

  def journey_hint_value
    MultiJson.load(cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT])
  rescue MultiJson::ParseError
    nil
  end

  # Clean up users' existing cookies, remove in March 2020
  def eat_journey_hint_cookie(cookie)
    yummy_cookie = cookie

    bad_crumbs = %w(CANCEL FAILED FAILED_UPLIFT PENDING OTHER entity_id)

    bad_crumbs.each { |old_status| yummy_cookie.delete(old_status) }

    yummy_cookie
  end
end
