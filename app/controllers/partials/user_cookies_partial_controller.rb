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

  def set_journey_hint(idp_entity_id)
    cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = { value: { entity_id: idp_entity_id }.to_json,
                                                                  expires: 18.months.from_now }
  end
end
