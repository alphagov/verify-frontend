require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  Idp = Struct.new(:display_name, :tagline)

  describe "#page_title" do
    it "should output English page title by default" do
      helper.page_title("hub.start.heading")
      expect(helper.content_for(:page_title)).to eql t("hub.start.heading")
    end

    it 'should start with "Error:" when there are page errors' do
      flash[:errors] = ["some error"]
      expected_title = "Error: #{t('hub.start.heading', locale: 'en')}"
      helper.page_title("hub.start.heading", locale: :en)
      expect(helper.content_for(:page_title)).to eql expected_title
    end

    it "raise ArgumentError when called with nil" do
      expect { helper.page_title(nil) }
        .to raise_error ArgumentError, "Missing page title"
    end

    it "should output Welsh page title if locale specified" do
      helper.page_title("hub.start.heading", locale: :cy)
      expect(helper.content_for(:page_title)).to eql t("hub.start.heading", locale: "cy")
    end

    it "should always output English page title and level of assurance for analytics" do
      title = "#{t('hub.start.heading', locale: 'en')} - GOV.UK Verify - LEVEL_1"
      session["requested_loa"] = "LEVEL_1"
      helper.page_title("hub.start.heading", locale: :cy)
      expect(helper.content_for(:page_title_in_english)).to eql title
    end

    it "should just output English page title when requested_loa not in session" do
      title = "#{t('hub.start.heading', locale: 'en')} - GOV.UK Verify"
      helper.page_title("hub.start.heading", locale: :cy)
      expect(helper.content_for(:page_title_in_english)).to eql title
    end
  end

  describe "#idp_tagline" do
    it "should output name and tagline if tagline is present" do
      idp_tagline = helper.idp_tagline(Idp.new("name", "tag"))
      expect(idp_tagline).to eq("name: tag")
    end
    it "should output name if tagline is not present" do
      idp_tagline = helper.idp_tagline(Idp.new("name", nil))
      expect(idp_tagline).to eq("name")
    end
  end

  describe "#button_link_to" do
    it "should pass through the text and path to link_to" do
      button = helper.button_link_to "My text", "/my_path"
      expect(button).to include('href="/my_path"')
      expect(button).to include("My text")
    end
    it 'should always have a class and role of "button"' do
      button = helper.button_link_to "", ""
      expect(button).to include('class="button"')
      expect(button).to include('role="button"')
    end
    it 'should append "button" to existing classes' do
      button = helper.button_link_to "", "", class: "test"
      expect(button).to include('class="test button"')
    end
    it 'should overwrite existing roles with "button"' do
      button = helper.button_link_to "", "", role: "test"
      expect(button).to include('role="button"')
      expect(button).not_to include('role="test"')
    end
  end

  describe "#hide_from_search_engine?" do
    it "should hide from search engine by default" do
      expect(helper.hide_from_search_engine?).to be true
    end

    it "should not hide from search engine if we have set to show for search engine" do
      helper.content_for(:show_to_search_engine, true)

      expect(helper.hide_from_search_engine?).to be false
    end

    it "should hide from search engine if we have set to hide for search engine" do
      helper.content_for(:show_to_search_engine, false)

      expect(helper.hide_from_search_engine?).to be true
    end
  end
end
