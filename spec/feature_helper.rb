require 'rails_helper'
require 'capybara/rspec'
require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)

Capybara.register_driver :no_js_selenium do |app|
  require 'selenium/webdriver'
  profile = Selenium::WebDriver::Firefox::Profile.new
  profile["javascript.enabled"] = false

  Capybara::Selenium::Driver.new(app, profile: profile)
end

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

def api_transactions_endpoint
  api_uri('transactions')
end

def stub_transactions_list
  transactions = {
      'public' => [
          { 'simpleId' => 'test-rp', 'entityId' => 'some-entity-id', 'homepage' => 'http://localhost:50130/test-rp' },
          { 'simpleId' => 'test-rp-noc3', 'entityId' => 'some-entity-id', 'homepage' => 'http://localhost:50130/test-rp-noc3' }
      ],
      'private' => [
          { 'simpleId' => 'headless-rp', 'entityId' => 'some-entity-id' },
      ]
  }
  stub_request(:get, api_transactions_endpoint).to_return(body: transactions.to_json, status: 200)
end

def stub_federation(idp_entity_id = 'http://idcorp.com')
  body = { 'idps' => [{ 'simpleId' => 'stub-idp-one', 'entityId' => idp_entity_id }], 'transactionSimpleId' => 'test-rp', 'transactionEntityId' => 'some-entity-id' }
  stub_request(:get, api_uri('session/federation')).to_return(body: body.to_json)
end

def stub_federation_no_docs
  body = { 'idps' => [{ 'simpleId' => 'stub-idp-no-docs', 'entityId' => 'http://idcorp.nodoc.com' }], 'transactionSimpleId' => 'test-rp', 'transactionEntityId' => 'some-id' }
  stub_request(:get, api_uri('session/federation')).to_return(body: body.to_json)
end

def create_session_start_time_cookie
  DateTime.now.to_i * 1000
end

def api_uri(path)
  URI.join(API_HOST, '/api/', path)
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
    journey_hint_cookie = Capybara.current_session.driver.browser.manage.all_cookies.detect do |cookie|
      cookie[:name] == cookie_name
    end
    journey_hint_cookie[:value]
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
      CookieNames::SESSION_STARTED_TIME_COOKIE_NAME => create_session_start_time_cookie,
      CookieNames::SESSION_ID_COOKIE_NAME => 'my-session-id-cookie',
  }
end

def set_session_cookies!
  cookie_hash = create_cookie_hash
  set_cookies!(cookie_hash)
  cookie_hash
end

def query_params
  current_uri = URI.parse(page.current_url)
  current_uri.query ? CGI::parse(current_uri.query) : {}
end
