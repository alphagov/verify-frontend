require "rails_helper"
require "capybara/rspec"
require "webmock/rspec"
require "webdrivers/chromedriver"
require "rack_session_access/capybara"
require "support/cookie_matchers"
WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: ["chromedriver.storage.googleapis.com",
          %r{github.com/mozilla/geckodriver/releases.*},
          %r{github-releases.githubusercontent.com/.*geckodriver}],
)

RACK_COOKIE_DATE_FORMAT = "%a, %d %b %Y".freeze

RSpec.configure do |config|
  config.before(:each, js: true) do
    page.driver.browser.manage.window.resize_to(1280, 1024)
  end
  # HUB-580: To run feature tests separately
  # Due to our multi-threading logic in the loading_cache for
  # transactions translations we have to boot up the application
  # to avoid deadlocks after each test
  VerifyFrontend::Application.eager_load!

  config.include AbstractController::Translation
end

require "selenium/webdriver"
if ENV["BROWSER"] == "chrome"
  browser = :chrome
  options = ::Selenium::WebDriver::Chrome::Options.new
else
  browser = :firefox
  options = ::Selenium::WebDriver::Firefox::Options.new
end

Capybara.register_driver :browser do |app|
  options.add_argument("--headless")

  Capybara::Selenium::Driver.new(app, browser: browser, options: options)
end

Capybara.javascript_driver = :browser
Capybara.server = :puma, { Silent: true }

module FeatureHelper
  def current_time_in_millis
    Time.now.to_i * 1000
  end

  def expect_feedback_source_to_be(page, source, feedback_source_path)
    expect(page).to have_link id: t("feedback_link.id"), href: "/feedback-landing?feedback-source=#{source}"
    expect(FEEDBACK_SOURCE_MAPPER.page_from_source(source, :en)).to eql(feedback_source_path)
  end

  def is_selenium_driver?
    driver = Capybara.current_session.driver
    driver.is_a? Capybara::Selenium::Driver
  end

  def set_cookies!(hash)
    driver = Capybara.current_session.driver
    visit "/test-saml" if is_selenium_driver?
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
    "my-session-id-cookie"
  end

  def create_cookie_hash
    {
      CookieNames::SESSION_COOKIE_NAME => "my-session-cookie",
      CookieNames::SESSION_ID_COOKIE_NAME => default_session_id,
    }
  end

  def create_cookie_hash_with_piwik_session
    create_cookie_hash.merge("_pk_id.1.ffff" => piwik_session_cookie_value)
  end

  def piwik_session_cookie_value
    session_id_value = piwik_session_id
    "#{session_id_value}.1544441431.1.1544441431.1544441431."
  end

  def piwik_session_id
    "cdf47f93f1419b32"
  end

  def start_time_in_millis
    Time.now.to_i * 1000
  end

  def set_session_and_session_cookies!(cookie_hash: create_cookie_hash, session: default_session)
    set_cookies!(cookie_hash)
    set_session!(session)
    cookie_hash
  end

  def set_loa_in_session(loa)
    page.set_rack_session(
      requested_loa: loa,
    )
  end

  def set_journey_type_in_session(journey_type)
    page.set_rack_session({ journey_type: journey_type })
  end

  def set_selected_idp_in_session(selected_idp)
    page.set_rack_session(selected_provider: SelectedProviderData.new(selected_idp))
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

  def set_journey_hint_cookie(entity_id, status = nil, locale = "en", rp_entity_id = nil, resume_link_entity_id = nil)
    visit "/test-journey-hint"
    fill_in "entity-id", with: entity_id
    fill_in "status", with: status
    fill_in "locale", with: locale
    fill_in "rp-entity-id", with: rp_entity_id
    fill_in "resume-link-simple-id", with: resume_link_entity_id

    click_button "journey-hint-post"
  end

  def cookie_header(cookie_name)
    set_cookies_headers = page.response_headers["Set-Cookie"].split(/\n/)
    set_cookies_headers.detect { |header| header.match(/^#{cookie_name}/) }
  end

  def initialise_journey_hint(journey_hint, journey_hint_rp = "test-rp")
    post "/test-initiate-journey", params: { journey_hint: journey_hint, journey_hint_rp: journey_hint_rp }
  end

  def default_session_loa1
    {
      transaction_simple_id: "test-rp",
      start_time: start_time_in_millis,
      verify_session_id: default_session_id,
      requested_loa: "LEVEL_1",
      transaction_entity_id: "http://www.test-rp.gov.uk/SAML2/MD",
      transaction_homepage: "http://www.test-rp.gov.uk/",
    }
  end

private

  def default_session
    {
      transaction_simple_id: "test-rp",
      start_time: start_time_in_millis,
      verify_session_id: default_session_id,
      requested_loa: "LEVEL_2",
      transaction_entity_id: "http://www.test-rp.gov.uk/SAML2/MD",
      transaction_homepage: "http://www.test-rp.gov.uk/",
    }
  end

  def navigate_to_feedback_form(locale = "en")
    click_link id: t("feedback_link.id")
    click_link t("hub.feedback_landing.feedback_form.heading", locale: locale)
  end
end

RSpec.configure do |c|
  c.include FeatureHelper
end

RSpec::Matchers.define :a_list_of_size do |x|
  match { |actual| actual.length == x }
end
