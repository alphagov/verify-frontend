require 'active_support/core_ext/module/delegation'
require 'models/display/idp_ranker'
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

    it 'will return a non viewable if provided a nil value' do
      result = decorator.decorate(nil)
      expect(result).to be_a(NotViewableIdentityProvider)
    end

    describe 'decorated with ranking' do
      let(:idp_list) { [idp(:idp_one), idp(:idp_two), idp(:idp_three)] }

      before(:each) do
        display_data = double(:display_data)
        expect(repository).to receive(:fetch).at_least(:once).and_return display_data
      end

      it 'returns a decorated IDP collection based on ranking' do
        ranking = Display::IdpRanking.new(%w(idp_two idp_three idp_one))

        result = decorator.decorate_collection_with_ranking(idp_list, ranking)

        expect(result.map(&:simple_id)).to eql %w(idp_two idp_three idp_one)
      end

      it 'returns a decorated IDP collection based on ranking with missing rank' do
        ranking = Display::IdpRanking.new(%w(idp_two idp_one))

        result = decorator.decorate_collection_with_ranking(idp_list, ranking)

        expect(result.map(&:simple_id)).to eql %w(idp_two idp_one idp_three)
      end

      it 'returns a decorated IDP collection based on ranking only one rank' do
        ranking = Display::IdpRanking.new(['idp_three'])

        result = decorator.decorate_collection_with_ranking(idp_list, ranking)

        expect(result.map(&:simple_id).first).to eql 'idp_three'
      end

      it 'returns a decorated IDP collection based on ranking with extra element' do
        ranking = Display::IdpRanking.new(%w(idp_two idp_three idp_one idp_four))

        result = decorator.decorate_collection_with_ranking(idp_list, ranking)

        expect(result.map(&:simple_id)).to eql %w(idp_two idp_three idp_one)
      end

      def idp(id)
        double(id, 'simple_id' => id.to_s, 'entity_id' => id.to_s)
      end
    end
  end
end
