require 'rails_helper'
require 'capybara/rspec'
require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)

def api_transactions_endpoint
  api_uri('transactions')
end

def stub_transactions_list
  transactions = {
      'public' => [
          {'simpleId' => 'test-rp', 'entityId' => 'some-entity-id', 'homepage' => 'http://localhost:50130/test-rp'}
      ],
      'private' => []
  }
  stub_request(:get, api_transactions_endpoint).to_return(body: transactions.to_json, status: 200)
end

def create_session_start_time_cookie
  DateTime.now.to_i * 1000
end

def api_uri(path)
  "#{API_HOST}/api/#{path}"
end

def expect_feedback_source_to_be(page, source)
  expect(page).to have_link 'feedback', href: "/feedback?feedback-source=#{source}"
end

def set_cookies!(hash)
  driver = Capybara.current_session.driver
  is_selenium_driver = driver.is_a? Capybara::Selenium::Driver
  visit '/test-saml' if is_selenium_driver
  hash.each do |key, value|
    if is_selenium_driver
      driver.browser.manage.add_cookie(name: key, value: value)
    else
      driver.browser.set_cookie "#{key}=#{value}"
    end
  end
end

def create_cookie_hash
  {
      CookieNames::SECURE_COOKIE_NAME => 'my-secure-cookie',
      CookieNames::SESSION_STARTED_TIME_COOKIE_NAME => create_session_start_time_cookie,
      CookieNames::SESSION_ID_COOKIE_NAME => 'my-session-id-cookie',
  }
end

def set_session_cookies!
  cookie_hash = create_cookie_hash
  set_cookies!(cookie_hash)
  cookie_hash
end
