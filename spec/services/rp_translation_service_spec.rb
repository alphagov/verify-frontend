require 'feature_helper'
require 'api_test_helper'
require 'rp_translation_service'
require 'models/display/federation_translator'
require 'models/config_proxy'
require 'i18n'

describe 'RpTranslationService' do
  before(:each) do
    allow(CONFIG_PROXY).to receive(:transactions).and_return(MultiJson.load('[{
      "simpleId":"test-rp",
      "entityId":"http://example.com/test-rp",
      "serviceHomepage":"http://example.com/test-rp",
      "loaList":["LEVEL_2"]
    }]'))

    @translator = instance_double("Display::FederationTranslator")

    I18n.backend = I18n::Backend::Simple.new
  end

  it 'should call to config service to get transactions' do
    translation_service = RpTranslationService.new(@translator)

    transactions = translation_service.transactions

    expect(CONFIG_PROXY).to have_received(:transactions)
    expect(transactions).to eq(['test-rp'])
  end

  it 'should update I18n with translations for a particular transaction in the current locale' do
    translations = {
      name: "register for an identity profile",
      rp_name: "Test RP",
      analytics_description: "analytics description for test-rp",
      other_ways_text: "<p>If you can’t verify your identity using GOV.UK Verify, you can register for an identity profile <a href=\"http://www.example.com\">here</a>.</p><p>Tell us your:</p><ul><li>name</li><li>age</li></ul><p>Include any other relevant details if you have them.</p>",
      other_ways_description: "register for an identity profile",
      tailored_text: "External data source: EN: This is tailored text for test-rp",
      taxon_name: "Benefits",
      custom_fail_heading: '',
      custom_fail_what_next_content: '',
      custom_fail_other_options: '',
      custom_fail_try_another_summary: '',
      custom_fail_try_another_text: '',
      custom_fail_contact_details_intro: ''
    }
    allow(CONFIG_PROXY).to receive(:get_transaction_translations).with('test-rp', :en).and_return(translations)

    translation_service = RpTranslationService.new(@translator)
    translation_service.update_rp_translations('test-rp')

    translations.keys.each do |key|
      expect(I18n.t("rps.test-rp.#{key}")).to eq(translations.fetch(key))
    end
  end

  it 'should keep existing translations when config proxy returns an empty hash' do
    translations = {
        name: "register for an identity profile",
        rp_name: "Test RP",
        analytics_description: "analytics description for test-rp",
        other_ways_text: "<p>If you can’t verify your identity using GOV.UK Verify, you can register for an identity profile <a href=\"http://www.example.com\">here</a>.</p><p>Tell us your:</p><ul><li>name</li><li>age</li></ul><p>Include any other relevant details if you have them.</p>",
        other_ways_description: "register for an identity profile",
        tailored_text: "External data source: EN: This is tailored text for test-rp",
        taxon_name: "Benefits",
        custom_fail_heading: '',
        custom_fail_what_next_content: '',
        custom_fail_other_options: '',
        custom_fail_try_another_summary: '',
        custom_fail_try_another_text: '',
        custom_fail_contact_details_intro: ''
    }
    allow(CONFIG_PROXY).to receive(:get_transaction_translations).with('test-rp', :en).and_return(translations, {})

    translation_service = RpTranslationService.new(@translator)
    translation_service.update_rp_translations('test-rp')
    translation_service.update_rp_translations('test-rp')

    expect(CONFIG_PROXY).to have_received(:get_transaction_translations).with('test-rp', :en).twice
    expect(I18n.t("rps.test-rp.name")).to eq("register for an identity profile")
    expect(I18n.t("rps.test-rp.rp_name")).to eq("Test RP")
  end

  it 'should only update individual translations when config proxy returns partial translations' do
    translations = {
        name: "register for an identity profile",
        rp_name: "Test RP",
        analytics_description: "analytics description for test-rp",
        other_ways_text: "<p>If you can’t verify your identity using GOV.UK Verify, you can register for an identity profile <a href=\"http://www.example.com\">here</a>.</p><p>Tell us your:</p><ul><li>name</li><li>age</li></ul><p>Include any other relevant details if you have them.</p>",
        other_ways_description: "register for an identity profile",
        tailored_text: "External data source: EN: This is tailored text for test-rp",
        taxon_name: "Benefits",
        custom_fail_heading: '',
        custom_fail_what_next_content: '',
        custom_fail_other_options: '',
        custom_fail_try_another_summary: '',
        custom_fail_try_another_text: '',
        custom_fail_contact_details_intro: ''
    }
    partial_translations = {
        rp_name: "Updated Test RP"
    }
    allow(CONFIG_PROXY).to receive(:get_transaction_translations).with('test-rp', :en).and_return(translations, partial_translations)

    translation_service = RpTranslationService.new(@translator)
    translation_service.update_rp_translations('test-rp')
    translation_service.update_rp_translations('test-rp')

    expect(CONFIG_PROXY).to have_received(:get_transaction_translations).with('test-rp', :en).twice
    expect(I18n.t("rps.test-rp.name")).to eq("register for an identity profile")
    expect(I18n.t("rps.test-rp.rp_name")).to eq("Updated Test RP")
  end
end
