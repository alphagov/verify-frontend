module CookieDeletionPartialController
  def delete_cookies_without_consent
    cookies.delete CookieNames::PIWIK_USER_ID

  end
end