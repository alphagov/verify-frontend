require 'rails_helper'
require 'capybara/rspec'
require 'webmock/rspec'
require 'rack_session_access/capybara'
require 'support/cookie_matchers'
WebMock.disable_net_connect!(allow_localhost: true)

if ENV['HEADLESS'] == 'true'
  require 'headless'
  headless = Headless.new
  headless.start
  at_exit do
    exit_status = $!.status if $!.is_a?(SystemExit)
    headless.destroy
    exit exit_status if exit_status
  end
end

def current_time_in_millis
  DateTime.now.to_i * 1000
end

def expect_feedback_source_to_be(page, source)
  expect(page).to have_link 'feedback', href: "/feedback?feedback-source=#{source}"
end

def is_selenium_driver?
  driver = Capybara.current_session.driver
  driver.is_a? Capybara::Selenium::Driver
end

def set_cookies!(hash)
  driver = Capybara.current_session.driver
  visit '/test-saml' if is_selenium_driver?
  hash.each do |key, value|
    if is_selenium_driver?
      driver.browser.manage.add_cookie(name: key, value: value)
    else
      driver.browser.set_cookie "#{key}=#{value}"
    end
  end
end

def cookie_value(cookie_name)
  if is_selenium_driver?
    all_cookies = Capybara.current_session.driver.browser.manage.all_cookies
    cookie = all_cookies.detect { |c| c[:name] == cookie_name }
    raise "Could not find cookie with name #{cookie_name.inspect}, cookies were #{all_cookies.inspect}" unless cookie
    cookie[:value]
  else
    Capybara.current_session.driver.request.cookies[cookie_name]
  end
end

def expect_cookie(cookie_name, cookie_value)
  expect(cookie_value(cookie_name)).to eql cookie_value
end

def create_cookie_hash
  {
      CookieNames::SECURE_COOKIE_NAME => 'my-secure-cookie',
      CookieNames::SESSION_STARTED_TIME_COOKIE_NAME => current_time_in_millis,
      CookieNames::SESSION_ID_COOKIE_NAME => 'my-session-id-cookie',
  }
end

def set_session_cookies!
  cookie_hash = create_cookie_hash
  set_cookies!(cookie_hash)
  page.set_rack_session(transaction_simple_id: 'test-rp')
  cookie_hash
end

def query_params
  current_uri = URI.parse(page.current_url)
  current_uri.query ? CGI::parse(current_uri.query) : {}
end

def set_journey_hint_cookie(entity_id, locale = 'en')
  visit '/test-journey-hint'
  fill_in 'entity-id', with: entity_id
  fill_in 'locale', with: locale
  click_button 'journey-hint-post'
end
