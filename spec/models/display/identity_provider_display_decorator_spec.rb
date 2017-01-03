require 'active_support/core_ext/module/delegation'
require 'models/display/identity_provider_display_decorator'
require 'models/display/viewable_identity_provider'
require 'models/display/not_viewable_identity_provider'
require 'logger_helper'

module Display
  describe IdentityProviderDisplayDecorator do
    let(:repository) { double(:repository) }
    let(:decorator) { IdentityProviderDisplayDecorator.new(repository, '/stub-logos', '/stub-logos/white') }

    it 'takes an IDP object and a repository with knowledge of IDPs and returns the IDP with display data' do
      idp = double(:idp_one, 'simple_id' => 'test-simple-id', 'entity_id' => 'test-entity-id')

      display_data = double(:display_data)
      expect(repository).to receive(:fetch).with('test-simple-id').and_return display_data
      result = decorator.decorate(idp)
      expected_result = ViewableIdentityProvider.new(
        idp,
        display_data,
        '/stub-logos/test-simple-id.png',
        '/stub-logos/white/test-simple-id.png',
        )
      expect(result).to eql expected_result
    end

    it 'returns a decorated IDP that is not viewable if display data is missing' do
      idp = double(:idp_one, 'simple_id' => 'test-simple-id', 'entity_id' => 'test-entity-id')
      expect(stub_logger).to receive(:error).at_least(:once)
      allow(repository).to receive(:fetch).with('test-simple-id').and_raise(KeyError)

      result = decorator.decorate(idp)
      expected_result = NotViewableIdentityProvider.new(idp)
      expect(result).to eql expected_result
    end

    it "will skip IDP if translations can't be found" do
      expect(stub_logger).to receive(:error).at_least(:once)

      allow(repository).to receive(:fetch).with('test-simple-id').and_raise(KeyError)
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
