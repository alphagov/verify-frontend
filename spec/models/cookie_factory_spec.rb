require 'spec_helper'
require 'models/cookie_names'
require 'models/cookie_factory'

describe CookieFactory do
  let(:cookie_hash) {
    {
      CookieNames::SESSION_STARTED_TIME_COOKIE_NAME => 0,
      CookieNames::SESSION_ID_COOKIE_NAME => "my-session-id",
      CookieNames::SECURE_COOKIE_NAME => "my-secure-cookie"
    }
  }
  let(:cookie_factory) { CookieFactory.new(true) }

  context 'given a hash' do
    it 'will create cookies with a domain, path, expiry time and secure flag' do
      cookies = cookie_factory.create(cookie_hash)
      check_cookie(cookies[CookieNames::SESSION_ID_COOKIE_NAME], 'my-session-id')
      check_cookie(cookies[CookieNames::SESSION_STARTED_TIME_COOKIE_NAME], 0)
      check_cookie(cookies[CookieNames::SECURE_COOKIE_NAME], 'my-secure-cookie')
    end

    def check_cookie(cookie, expected_cookie_value)
      expect(cookie[:value]).to eq expected_cookie_value
      expect(cookie[:secure]).to eq true
      expect(cookie[:path]).to eq '/'
      expect(cookie[:httponly]).to eq true
    end
  end
end
