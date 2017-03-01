require 'rails_helper'
require 'capybara/rspec'
require 'webmock/rspec'
require 'rack_session_access/capybara'
require 'support/cookie_matchers'
WebMock.disable_net_connect!(allow_localhost: true)

RACK_COOKIE_DATE_FORMAT = "%a, %d %b %Y".freeze

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

RSpec.configure do |config|
  config.before(:each, js: true) do
    page.driver.browser.manage.window.resize_to(1280, 1024)
  end
end

Capybara.configure do |config|
  config.server = :puma
end

module FeatureHelper
  def current_time_in_millis
    DateTime.now.to_i * 1000
  end

  def expect_feedback_source_to_be(page, source, feedback_source_path)
    expect(page).to have_link 'feedback', href: "/feedback?feedback-source=#{source}"
    expect(FeedbackSourceMapper.page_from_source(source, :en)).to eql(feedback_source_path)
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
      Capybara.current_session.driver.browser.rack_mock_session.cookie_jar[cookie_name]
    end
  end

  def expect_cookie(cookie_name, cookie_value)
    expect(cookie_value(cookie_name)).to eql cookie_value
  end

  def default_session_id
    'my-session-id-cookie'
  end

  def create_cookie_hash
    {
        CookieNames::SESSION_COOKIE_NAME => 'my-session-cookie',
        CookieNames::SESSION_ID_COOKIE_NAME => default_session_id,
    }
  end

  def start_time_in_millis
    DateTime.now.to_i * 1000
  end

  def set_session_and_session_cookies!(idps = [{ 'simple_id' => 'stub-idp-one', 'entity_id' => 'http://idcorp.com' },
                                               { 'simple_id' => 'stub-idp-two', 'entity_id' => 'other-entity-id' },
                                               { 'simple_id' => 'stub-idp-three', 'entity_id' => 'a-different-entity-id' },
                                               { 'simple_id' => 'stub-idp-demo', 'entity_id' => 'demo-entity-id' }])
    cookie_hash = create_cookie_hash
    set_cookies!(create_cookie_hash)
    page.set_rack_session(
      transaction_simple_id: 'test-rp',
      start_time: start_time_in_millis,
      verify_session_id: default_session_id,
      identity_providers: idps)
    cookie_hash
  end

  def set_stub_federation_in_session(idp_entity_id)
    idps = [
        { 'simple_id' => 'stub-idp-one', 'entity_id' => idp_entity_id }
    ]
    page.set_rack_session(identity_providers: idps)
  end

  def set_stub_federation_no_docs_in_session
    idps = [
        { 'simple_id' => 'stub-idp-one', 'entity_id' => 'http://idcorp.com' },
        { 'simple_id' => 'stub-idp-no-docs', 'entity_id' => 'http://idcorp.nodoc.com' },
        { 'simple_id' => 'stub-idp-two', 'entity_id' => 'other-entity-id' },
        { 'simple_id' => 'stub-idp-three', 'entity_id' => 'a-different-entity-id' }
    ]
    page.set_rack_session(identity_providers: idps)
  end

  def set_stub_federation_unavailable_in_session
    idps = [
        { 'simple_id' => 'stub-idp-one', 'entity_id' => 'http://idcorp.com' },
        { 'simple_id' => 'stub-idp-two', 'entity_id' => 'other-entity-id' },
        { 'simple_id' => 'stub-idp-three', 'entity_id' => 'a-different-entity-id' },
        { 'simple_id' => 'stub-idp-unavailable', 'entity_id' => 'unavailable-entity-id' }
    ]
    page.set_rack_session(identity_providers: idps)
  end

  def set_session_cookies!
    cookie_hash = create_cookie_hash
    set_cookies!(create_cookie_hash)
    cookie_hash
  end

  def set_session!(session = { transaction_simple_id: 'test-rp', start_time: start_time_in_millis, verify_session_id: default_session_id })
    page.set_rack_session(session)
    session
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

  def cookie_header(cookie_name)
    set_cookies_headers = page.response_headers['Set-Cookie'].split(/\n/)
    set_cookies_headers.detect { |header| header.match(/^#{cookie_name}/) }
  end
end

RSpec.configure do |c|
  c.include FeatureHelper
end
