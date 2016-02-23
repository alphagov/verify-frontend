require 'i18n'
require 'models/display/federation_translator'

module Display
  describe FederationTranslator do
    let(:federation_translator) { FederationTranslator.new }
    before(:each) { I18n.backend.store_translations :en, name: 'Bob' }
    it 'will translate a given key' do
      expect(federation_translator.translate('name')).to eql 'Bob'
    end
    it "will raise an error if the key can't be found" do
      expect { federation_translator.translate('foobar') }.to raise_error FederationTranslator::TranslationError
    end
  end
end
