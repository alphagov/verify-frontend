require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'locale is set based on multiple sources', type: :feature do
  context "when I visit a page" do
    it 'will set the locale cookie to en if the language is English', js: true do
      set_session_cookies!
      visit start_path
      expect(cookie_value(CookieNames::VERIFY_LOCALE)).to have_a_signed_value_of 'en'
    end

    it 'will set the locale cookie to cy if the page language is Welsh', js: true do
      set_session_cookies!
      visit about_cy_path
      expect(cookie_value(CookieNames::VERIFY_LOCALE)).to have_a_signed_value_of 'cy'
    end

    it 'will change the value of the locale cookie when the user changes from English to Welsh', js: true do
      set_session_cookies!
      visit start_path
      expect(cookie_value(CookieNames::VERIFY_LOCALE)).to have_a_signed_value_of 'en'
      click_on 'Cymraeg'
      expect(cookie_value(CookieNames::VERIFY_LOCALE)).to have_a_signed_value_of 'cy'
    end
  end
end
