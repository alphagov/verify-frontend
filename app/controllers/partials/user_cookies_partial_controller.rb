module UserCookiesPartialController
  include AbTestConstraint
  def set_secure_cookie(name, value)
    cookies[name] = {
        value: value,
        httponly: true,
        secure: Rails.configuration.x.cookies.secure,
    }
  end

  def set_visitor_cookie
    cookies[CookieNames::PIWIK_USER_ID] = SecureRandom.hex(8) unless cookies.has_key? CookieNames::PIWIK_USER_ID
  end

  def store_locale_in_cookie
    cookies.signed[CookieNames::VERIFY_LOCALE] = {
        value: I18n.locale,
        httponly: true,
        secure: Rails.configuration.x.cookies.secure,
    }
  end

  def set_attempt_journey_hint(idp_entity_id)
    journey_hint_value_hash = journey_hint_value || {}
    journey_hint_value_hash["ATTEMPT"] = idp_entity_id

    cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = { value: journey_hint_value_hash.to_json,
                                                                  expires: 18.months.from_now }
  end

  def set_journey_hint_by_status(idp_entity_id, status, rp_entity_id = nil)
    return if idp_entity_id.nil?

    journey_hint_by_status_value = journey_hint_value || {}
    journey_hint_by_status_value["SUCCESS"] = idp_entity_id if status == "SUCCESS"
    journey_hint_by_status_value["STATE"] = { IDP: idp_entity_id,
                                              RP: rp_entity_id.nil? ? session[:transaction_entity_id] : rp_entity_id,
                                              STATUS: status }
    journey_hint_by_status_value["STATE"][:VERIFY_JOURNEY_TYPE] = session[:journey_type] if status == "PENDING"

    cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = { value: journey_hint_by_status_value.to_json, expires: 18.months.from_now }
  end

  def set_resume_link_journey_hint(idp_simple_id)
    journey_hint_value_hash = journey_hint_value || {}
    journey_hint_value_hash["RESUMELINK"] = {
      IDP: idp_simple_id,
    }

    cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = { value: journey_hint_value_hash.to_json,
                                                                  expires: 18.months.from_now }
  end

  def remove_resume_link_journey_hint
    journey_hint_value_hash = journey_hint_value || {}
    journey_hint_value_hash.delete("RESUMELINK")

    cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = { value: journey_hint_value_hash.to_json,
                                                                  expires: 18.months.from_now }
  end

  def remove_success_journey_hint
    journey_hint_value_hash = journey_hint_value || {}
    journey_hint_value_hash.delete("SUCCESS")

    cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = { value: journey_hint_value_hash.to_json,
                                                                  expires: 18.months.from_now }
  end

  def set_single_idp_journey_cookie(data)
    cookies.encrypted[CookieNames::VERIFY_SINGLE_IDP_JOURNEY] = {
      value: data.to_json,
      expires: Integer(CONFIG.session_cookie_duration_mins).minutes.from_now,
    }
  end

private

  def journey_hint_value
    MultiJson.load(cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT])
  rescue MultiJson::ParseError
    nil
  end

  def ab_test_with_alternative_name
    return unless AbTest.respond_to?(:report_ab_test_details) && experiment_name.present?

    AbTest.report_ab_test_details(request, experiment_name)
  end
end
