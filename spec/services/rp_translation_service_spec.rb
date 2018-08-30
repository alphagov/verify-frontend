require 'feature_helper'
require 'api_test_helper'
require 'rp_translation_service'
require 'models/config_proxy'
require 'i18n'

describe 'RpTranslationService' do
  let(:config_proxy) { instance_double("ConfigProxy") }
  before(:each) do
    stub_const("CONFIG_PROXY", config_proxy)

    I18n.backend = I18n::Backend::Simple.new
  end

  it 'should call to config service to get transactions' do
    translation_service = RpTranslationService.new
    expect(config_proxy).to receive(:transactions).and_return(MultiJson.load('[{
      "simpleId":"test-rp",
      "entityId":"http://example.com/test-rp",
      "serviceHomepage":"http://example.com/test-rp",
      "loaList":["LEVEL_2"]
    }]'))

    transactions = translation_service.transactions

    expect(transactions).to eq(['test-rp'])
  end

  it 'should update I18n with translations for a particular transaction in all locales' do
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
    translations_cy = translations.map { |key, value| [key, value + " cy"] }.to_h
    expect(config_proxy).to receive(:get_transaction_translations).with('test-rp', "en").and_return(translations)
    expect(config_proxy).to receive(:get_transaction_translations).with('test-rp', "cy").and_return(translations_cy)

    translation_service = RpTranslationService.new
    translation_service.update_rp_translations('test-rp')

    translations.keys.each do |key|
      expect(I18n.t("rps.test-rp.#{key}", locale: :en)).to eq(translations.fetch(key))
      expect(I18n.t("rps.test-rp.#{key}", locale: :cy)).to_not eq(translations.fetch(key))
      expect(I18n.t("rps.test-rp.#{key}", locale: :cy)).to eq(translations_cy.fetch(key))
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
    expect(config_proxy).to receive(:get_transaction_translations).with('test-rp', 'en').and_return(translations, {})
    expect(config_proxy).to receive(:get_transaction_translations).with('test-rp', 'cy').and_return(translations, {})

    translation_service = RpTranslationService.new
    translation_service.update_rp_translations('test-rp')
    translation_service.update_rp_translations('test-rp')

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
    expect(config_proxy).to receive(:get_transaction_translations).with('test-rp', 'en').and_return(translations, partial_translations)
    expect(config_proxy).to receive(:get_transaction_translations).with('test-rp', 'cy').and_return(translations, partial_translations)

    translation_service = RpTranslationService.new
    translation_service.update_rp_translations('test-rp')
    translation_service.update_rp_translations('test-rp')

    expect(I18n.t("rps.test-rp.name")).to eq("register for an identity profile")
    expect(I18n.t("rps.test-rp.rp_name")).to eq("Updated Test RP")
  end
end
