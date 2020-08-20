require "feature_helper"
require "api_test_helper"
require "mock_piwik_middleware"
require "cookie_names"

RSpec.describe "When the user visits a page" do
  let(:request_log) { double(:request_log) }

  before(:all) do
    Rails.application.routes.append do
      get "piwik.php", to: MockPiwikMiddleware.new, as: :test_piwik
    end
    Rails.application.reload_routes!
  end

  before(:each) do
    visit "/test-saml" #get Rails app host
    @server_url = URI.join(current_url, test_piwik_path).to_s
    allow(MockPiwikMiddleware).to receive(:request_log).and_return(request_log)
    expect(PUBLIC_PIWIK).to receive(:url).and_return(@server_url).at_least(2).times
  end

  context "when JS is enabled", js: true do
    it "sends a page view to analytics" do
      expect(request_log).to receive(:log).with(
        hash_including(
          "action_name" => "Start - GOV.UK Verify - GOV.UK - LEVEL_2",
          "idsite" => "5",
        ),
      )
      set_session_and_session_cookies!
      visit "/start"
      expect(page).to have_content t("hub.start.heading")
    end

    it "and in Welsh sends the page title in English to analytics" do
      expect(request_log).to receive(:log).with(
        hash_including(
          "action_name" => "Start - GOV.UK Verify - GOV.UK - LEVEL_2",
          "idsite" => "5",
        ),
      )
      set_session_and_session_cookies!
      visit "/dechrau"
    end

    it "sends a page view with a custom url for error pages" do
      browser = Capybara.current_session.driver.browser
      browser.manage.delete_all_cookies
      stub_transactions_list
      expect(request_log).to receive(:log).with(
        hash_including(
          "action_name" => "Cookies Missing - GOV.UK Verify - GOV.UK",
          "url" => /cookies-not-found/,
        ),
      )
      visit "/start"
      expect(page).to have_content t("errors.no_cookies.enable_cookies")
    end

    it "sends an event to Piwik only when the user changes selection, on the start page" do
      stub_transactions_list
      set_session_and_session_cookies!
      expect(request_log).to receive(:log).with(
        hash_including(
          "action_name" => "Start - GOV.UK Verify - GOV.UK - LEVEL_2",
        ),
      )
      expect(request_log).to receive(:log).with(
        hash_including(
          "e_c" => "Journey",
          "e_n" => "user_type",
          "e_a" => "Change to First Time",
        ),
      ).exactly(1).times
      expect(request_log).not_to receive(:log).with(
        hash_including(
          "e_c" => "Journey",
          "e_n" => "user_type",
          "e_a" => "Change to Sign In",
        ),
      )
      visit "/start"
      choose "start_form_selection_false", allow_label_click: true
      choose "start_form_selection_false", allow_label_click: true
      choose "start_form_selection_true", allow_label_click: true
      click_button "Continue"
    end

    it "sends a page view with a new_visit parameter if new session" do
      set_session_and_session_cookies!
      page.set_rack_session(new_visit: "true")
      expect(request_log).to receive(:log).with(
        hash_including(
          "action_name" => "Start - GOV.UK Verify - GOV.UK - LEVEL_2",
          "url" => /start/,
          "new_visit" => "1",
        ),
      )
      visit "/start"
    end

    it "sends a page view with a new_visit parameter if new session and on refresh the parameter is not present" do
      set_session_and_session_cookies!
      page.set_rack_session(new_visit: "true")
      expect(request_log).to receive(:log).with(
        hash_including(
          "action_name" => "Start - GOV.UK Verify - GOV.UK - LEVEL_2",
          "url" => /start/,
          "new_visit" => "1",
        ),
      )
      visit "/start"

      expect(request_log).to receive(:log).with(
        hash_including(
          "action_name" => "Start - GOV.UK Verify - GOV.UK - LEVEL_2",
          "url" => /start/,
          "new_visit" => "0",
        ),
      )
      visit "/start"
    end

    it "sends a page view with a new_visit parameter if new session and on next page the parameter is not present" do
      set_session_and_session_cookies!
      page.set_rack_session(new_visit: "true")

      expect(request_log).to receive(:log).with(
        hash_including(
          "action_name" => "Start - GOV.UK Verify - GOV.UK - LEVEL_2",
          "url" => /start/,
          "new_visit" => "1",
        ),
      )
      visit "/start"

      expect(request_log).to receive(:log).with(
        hash_including(
          "action_name" => "About - GOV.UK Verify - GOV.UK - LEVEL_2",
          "url" => /about/,
          "new_visit" => "0",
        ),
      )
      visit "/about"
    end
  end

  context "when JS is disabled" do
    it "sends a page view to analytics" do
      set_session_and_session_cookies!
      visit "/start"
      expect(page).to have_content t("hub.start.heading")
      noscript_image = page.find(:id, "piwik-noscript-tracker")
      expect(noscript_image).to_not be_nil
      image_src = noscript_image["src"]
      expect(image_src).to match(/piwik.php\?/)
      expect(image_src).to match(/idsite=5/)
      expect(image_src).to match(/rec=1/)
      expect(image_src).to match(/rand=\d+/)
      expect(image_src).to match(/action_name=Start\+-\+GOV\.UK\+Verify\+-\+GOV\.UK\+-\+LEVEL_2/)
      expect(image_src).to_not include("url")
    end

    it "and in Welsh sends the page title in English to analytics" do
      set_session_and_session_cookies!
      visit "/dechrau"
      noscript_image = page.find(:id, "piwik-noscript-tracker")
      expect(noscript_image).to_not be_nil
      image_src = noscript_image["src"]
      expect(image_src).to match(/action_name=Start\+-\+GOV\.UK\+Verify\+-\+GOV\.UK\+-\+LEVEL_2/)
    end

    it "sends a page view with a custom url for error pages" do
      browser = Capybara.current_session.driver.browser
      browser.clear_cookies
      stub_transactions_list
      visit "/start"
      expect(page).to have_content t("errors.no_cookies.enable_cookies")
      noscript_image = page.find(:id, "piwik-noscript-tracker")
      expect(noscript_image).to_not be_nil
      image_src = noscript_image["src"]
      expect(image_src).to match(/piwik.php\?/)
      expect(image_src).to match(/idsite=5/)
      expect(image_src).to match(/rec=1/)
      expect(image_src).to match(/rand=\d+/)
      expect(image_src).to match(/action_name=Cookies\+Missing\+-\+GOV\.UK\+Verify\+-\+GOV\.UK/)
      expect(image_src).to match(/url=[^&]+cookies-not-found/)
    end

    it "sends a page view with a new_visit parameter when new visit" do
      set_session_and_session_cookies!
      page.set_rack_session(new_visit: "true")
      visit "/start"
      noscript_image = page.find(:id, "piwik-noscript-tracker")
      expect(noscript_image).to_not be_nil
      image_src = noscript_image["src"]
      expect(image_src).to match(/piwik.php\?/)
      expect(image_src).to match(/idsite=5/)
      expect(image_src).to match(/rec=1/)
      expect(image_src).to match(/new_visit=1/)
      expect(image_src).to match(/rand=\d+/)
      expect(image_src).to match(/action_name=Start\+-\+GOV\.UK\+Verify\+-\+GOV\.UK\+-\+LEVEL_2/)
    end

    it "sends a page view with a new_visit parameter when new visit but not on the following refresh" do
      set_session_and_session_cookies!
      page.set_rack_session(new_visit: "true")
      visit "/start"
      noscript_image = page.find(:id, "piwik-noscript-tracker")
      expect(noscript_image).to_not be_nil
      image_src = noscript_image["src"]
      expect(image_src).to match(/new_visit=1/)
      expect(image_src).to match(/action_name=Start\+-\+GOV\.UK\+Verify\+-\+GOV\.UK\+-\+LEVEL_2/)

      visit "/start"
      noscript_image = page.find(:id, "piwik-noscript-tracker")
      expect(noscript_image).to_not be_nil
      image_src = noscript_image["src"]
      expect(image_src).to match(/new_visit=0/)
      expect(image_src).to match(/action_name=Start\+-\+GOV\.UK\+Verify\+-\+GOV\.UK\+-\+LEVEL_2/)
    end
  end
end
