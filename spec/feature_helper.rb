require 'rails_helper'
require 'capybara/rspec'
require 'webmock/rspec'
require 'rack_session_access/capybara'
require 'support/cookie_matchers'
WebMock.disable_net_connect!(allow_localhost: true)

RACK_COOKIE_DATE_FORMAT = "%a, %d %b %Y".freeze

RSpec.configure do |config|
  config.before(:each, js: true) do
    page.driver.browser.manage.window.resize_to(1280, 1024)
  end
  config.include AbstractController::Translation
end

require 'selenium/webdriver'
Capybara.register_driver :firefox_headless do |app|
  options = ::Selenium::WebDriver::Firefox::Options.new
  # Stop firefox getting upgraded to version 63 which does not work with Selenium.
  options.add_preference('app.update.auto', false)
  options.add_preference('app.update.enabled', false)
  options.add_argument('--headless')

  Capybara::Selenium::Driver.new(app, browser: :firefox, options: options)
end

Capybara.javascript_driver = :firefox_headless

module FeatureHelper
  def current_time_in_millis
    Time.now.to_i * 1000
  end

  def expect_feedback_source_to_be(page, source, feedback_source_path)
    expect(page).to have_link 'feedback', href: "/feedback?feedback-source=#{source}"
    expect(FEEDBACK_SOURCE_MAPPER.page_from_source(source, :en)).to eql(feedback_source_path)
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
      cookie ? cookie[:value] : nil
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
    Time.now.to_i * 1000
  end

  def set_session_and_session_cookies!(cookie_hash: create_cookie_hash, session: default_session)
    set_cookies!(cookie_hash)
    set_session!(session)
    cookie_hash
  end

  def set_session_and_ab_session_cookies!(experiment, cookie_hash = create_cookie_hash)
    cookie_hash[CookieNames::AB_TEST] = experiment.to_json
    set_cookies!(cookie_hash)
    set_session!(variant_session)
    cookie_hash
  end

  def set_cookies_and_ab_test_cookie!(experiment, cookie_hash = create_cookie_hash)
    cookie_hash[CookieNames::AB_TEST] = experiment.to_json
    set_cookies!(cookie_hash)
  end

  def set_loa_in_session(loa)
    page.set_rack_session(
      requested_loa: loa
    )
  end

  def set_selected_idp_in_session(selected_idp)
    page.set_rack_session(
      selected_provider: SelectedProviderData.new(JourneyType::VERIFY, selected_idp)
    )
  end

  def set_selected_country_in_session(selected_country)
    page.set_rack_session(
      selected_provider: SelectedProviderData.new(JourneyType::EIDAS, selected_country)
    )
  end

  def set_session_cookies!
    cookie_hash = create_cookie_hash
    set_cookies!(create_cookie_hash)
    cookie_hash
  end

  def set_session!(session = default_session)
    page.set_rack_session(session)
    session
  end

  def query_params
    current_uri = URI.parse(page.current_url)
    current_uri.query ? CGI::parse(current_uri.query) : {}
  end

  def set_journey_hint_cookie(entity_id, status = nil, locale = 'en', rp_entity_id = nil, resume_link_entity_id = nil)
    visit '/test-journey-hint'
    fill_in 'entity-id', with: entity_id
    fill_in 'status', with: status
    fill_in 'locale', with: locale
    fill_in 'rp-entity-id', with: rp_entity_id
    fill_in 'resume-link-simple-id', with: resume_link_entity_id

    click_button 'journey-hint-post'
  end

  def cookie_header(cookie_name)
    set_cookies_headers = page.response_headers['Set-Cookie'].split(/\n/)
    set_cookies_headers.detect { |header| header.match(/^#{cookie_name}/) }
  end

private

  def default_session
    {
      transaction_simple_id: 'test-rp',
      start_time: start_time_in_millis,
      verify_session_id: default_session_id,
      requested_loa: 'LEVEL_2',
      transaction_entity_id: 'http://www.test-rp.gov.uk/SAML2/MD',
      transaction_homepage: 'http://www.test-rp.gov.uk/',
      selected_answers: { device_type: { device_type_other: true } },
    }
  end

  def variant_session
    {
        transaction_simple_id: 'test-rp',
        start_time: start_time_in_millis,
        verify_session_id: default_session_id,
        requested_loa: 'LEVEL_2',
        transaction_entity_id: 'http://www.test-rp.gov.uk/SAML2/MD',
        transaction_homepage: 'http://www.test-rp.gov.uk/',
        selected_answers: { documents: { driving_licence: false }, device_type: { device_type_other: true } },
    }
  end
end

RSpec.configure do |c|
  c.include FeatureHelper
end
