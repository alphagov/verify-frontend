require 'spec_helper'
require 'models/display/rp/transaction_info_getter'
require 'rails_helper'

module Display
  module Rp
    describe TransactionInfoGetter do
      let(:session_proxy) { double(:session_proxy) }
      let(:cookie_jar) { double(:cookie_jar) }
      let(:repository) { double(:repository) }

      it 'should return the transaction info' do
        federation_info = FederationInfoResponse.new('idps' => [], 'transactionSimpleId' => 'simple-id', 'transactionEntityId' => 'entity-id')
        expect(session_proxy).to receive(:federation_info_for_session).with(cookie_jar).and_return(federation_info)
        expect(repository).to receive(:fetch).with('simple-id').and_return(OpenStruct.new(other_ways_description: 'Other ways description', other_ways_text: 'Other ways text'))

        result = described_class.new(session_proxy, repository).get_info(cookie_jar)

        expect(result.other_ways_description).to eql('Other ways description')
        expect(result.other_ways_text).to eql('Other ways text')
      end
    end
  end
end
