require 'feature_helper'
require 'api_test_helper'
require 'models/display/federation_translator'
require 'models/display/rp_display_repository'

module Display
  describe RpDisplayRepository do
    before(:each) do
      @translations = {
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
      @translator = instance_double("Display::FederationTranslator")
      allow(@translator).to receive(:translate).and_return("")

      RP_TRANSLATION_SERVICE = instance_double("RpTranslationService")
      allow(RP_TRANSLATION_SERVICE).to receive(:transactions).and_return(['test-rp'])
      allow(RP_TRANSLATION_SERVICE).to receive(:update_rp_translations).with('test-rp').and_return(@translations)
    end


    it 'should update all translations when display data is empty' do
      rp_display_repo = RpDisplayRepository.new(@translator)
      rp_display_repo.update_all_translations

      expect(RP_TRANSLATION_SERVICE).to have_received(:transactions)
      expect(rp_display_repo.instance_variable_get('@display_data').keys).to eq(['test-rp'])
      expect(rp_display_repo.instance_variable_get('@display_data').fetch('test-rp')).to be_a(Display::RpDisplayData)
    end

    it 'should not update all translations when translations are already cached' do
      rp_display_repo = RpDisplayRepository.new(@translator)
      rp_display_repo.update_all_translations
      rp_display_repo.update_all_translations

      expect(RP_TRANSLATION_SERVICE).to have_received(:transactions).once
    end

    it 'should get translations for a transaction when cached translations are available' do
      rp_display_repo = RpDisplayRepository.new(@translator)
      rp_display_repo.update_all_translations

      rp_display_repo.get_translations('test-rp')

      expect(RP_TRANSLATION_SERVICE).to have_received(:update_rp_translations).with('test-rp').exactly(12).times
    end

    it 'should update translations for a particular transaction when no cached translations are available' do
      allow(RP_TRANSLATION_SERVICE).to receive(:update_rp_translations).with('new-rp').and_return(@translations)

      rp_display_repo = RpDisplayRepository.new(@translator)
      rp_display_repo.update_all_translations

      rp_display_repo.get_translations('new-rp')

      expect(RP_TRANSLATION_SERVICE).to have_received(:update_rp_translations).with('new-rp').exactly(12).times
    end
  end
end
