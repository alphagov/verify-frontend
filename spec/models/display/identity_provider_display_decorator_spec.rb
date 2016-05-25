require 'active_support/core_ext/module/delegation'
require 'models/display/identity_provider_display_decorator'
require 'models/display/viewable_identity_provider'
require 'models/display/not_viewable_identity_provider'
require 'models/display/federation_translator'
require 'logger_helper'

module Display
  describe IdentityProviderDisplayDecorator do
    let(:translator) { double(:translator) }
    let(:decorator) { IdentityProviderDisplayDecorator.new(translator, '/stub-logos', '/stub-logos/white') }

    it 'takes an IDP object and a translator with knowledge of IDPs and returns the IDP with display data' do
      idp = double(:idp_one, 'simple_id' => 'test-simple-id', 'entity_id' => 'test-entity-id')
      requirements = ['requirement 1', 'requirement 2']

      expect(translator).to receive(:translate).with('idps.test-simple-id.name').and_return('Test Display Name')
      expect(translator).to receive(:translate).with('idps.test-simple-id.tagline').and_return('A great tagline')
      expect(translator).to receive(:translate).with('idps.test-simple-id.about').and_return('Test About Content')
      expect(translator).to receive(:translate).with('idps.test-simple-id.requirements').and_return(requirements)
      expect(translator).to receive(:translate).with('idps.test-simple-id.special_no_docs_instructions_html').and_return('instructions html')
      expect(translator).to receive(:translate).with('idps.test-simple-id.no_docs_requirement').and_return('no docs requirement')
      expect(translator).to receive(:translate).with('idps.test-simple-id.contact_details').and_return('an address')

      result = decorator.decorate(idp)
      expected_result = ViewableIdentityProvider.new(
        idp,
        'Test Display Name',
        'A great tagline',
        '/stub-logos/test-simple-id.png',
        '/stub-logos/white/test-simple-id.png',
        'Test About Content',
        requirements,
        'instructions html',
        'no docs requirement',
        'an address'
        )
      expect(result).to eql expected_result
    end

    it 'returns a decorated IDP that is not viewable if display data is missing' do
      idp = double(:idp_one, 'simple_id' => 'test-simple-id', 'entity_id' => 'test-entity-id')
      translation_error = Display::FederationTranslator::TranslationError.new

      expect(stub_logger).to receive(:error).with(translation_error).at_least(:once)
      allow(translator).to receive(:translate).with('idps.test-simple-id.name').and_raise(translation_error)

      result = decorator.decorate(idp)
      expected_result = NotViewableIdentityProvider.new(idp)
      expect(result).to eql expected_result
    end

    it "will skip IDP if translations can't be found" do
      translation_error = Display::FederationTranslator::TranslationError.new
      expect(stub_logger).to receive(:error).with(translation_error).at_least(:once)

      allow(translator).to receive(:translate).with('idps.test-simple-id.name').and_raise(translation_error)
      idp = double(:idp_one, 'simple_id' => 'test-simple-id', 'entity_id' => 'test-entity-id')
      idp_list = [idp]
      result = decorator.decorate_collection(idp_list)
      expect(result).to eql []
    end

    it "will return a non viewable if provided a nil value" do
      result = decorator.decorate(nil)
      expect(result).to be_a(NotViewableIdentityProvider)
    end
  end
end
