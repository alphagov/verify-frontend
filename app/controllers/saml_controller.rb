class SamlController < ApplicationController
  def set_locale
    I18n.locale = language_from_param || locale_from_locale_cookie || I18n.default_locale
  end

private

  def language_from_param
    language = params[:language]
    %w{en cy}.detect { |available_locale| available_locale == language }
  end

  def locale_from_locale_cookie
    cookies.signed[CookieNames::VERIFY_LOCALE]
  end
end
