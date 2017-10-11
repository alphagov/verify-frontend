require 'i18n'
require 'models/display/federation_translator'

module Display
  describe FederationTranslator do
    before(:all) {
      I18n.available_locales = %i[en cy]
      @current_locale = I18n.locale
    }
    after(:all) { I18n.locale = @current_locale }
    let(:federation_translator) { FederationTranslator.new }
    before(:each) { I18n.backend.store_translations :en, name: 'Bob' }

    it 'will translate a given key' do
      expect(federation_translator.translate('name')).to eql 'Bob'
    end

    it "will raise an error if the key can't be found" do
      expect { federation_translator.translate('foobar') }.to raise_error FederationTranslator::TranslationError
    end

    it "will fall back to English if a key can't be found for another locale" do
      I18n.locale = :cy
      expect(federation_translator.translate('name')).to eql("Bob")
    end

    it "will raise an error if the key can't be found for another locale or English" do
      I18n.locale = :cy
      expect { federation_translator.translate('foobar') }.to raise_error FederationTranslator::TranslationError
    end
  end
end
