require 'spec_helper'
require 'models/display/rp/transaction_info_getter'
require 'rails_helper'

module Display
  module Rp
    describe TransactionInfoGetter do
      let(:session_proxy) { double(:session_proxy) }
      let(:cookie_jar) { double(:cookie_jar) }
      let(:session) { { 'transaction_simple_id' => 'simple-id' } }
      let(:repository) { double(:repository) }

      it 'should return the transaction info from api' do
        simple_id = 'simple-id'
        federation_info = FederationInfoResponse.new('idps' => [], 'transactionSimpleId' => simple_id, 'transactionEntityId' => '')
        other_ways_data = OpenStruct.new(other_ways_description: 'Other ways description', other_ways_text: 'Other ways text')
        expect(session_proxy).to receive(:federation_info_for_session).with(cookie_jar).and_return(federation_info)
        expect(repository).to receive(:fetch).with(simple_id).and_return(other_ways_data)
        result = TransactionInfoGetter.new(session_proxy, repository).get_info(cookie_jar, {})
        expect(result).to eql(other_ways_data)
      end

      it 'should return the transaction info from session' do
        simple_id = 'simple-id'
        other_ways_data = OpenStruct.new(other_ways_description: 'Other ways description', other_ways_text: 'Other ways text')
        expect(repository).to receive(:fetch).with(simple_id).and_return(other_ways_data)
        result = TransactionInfoGetter.new(session_proxy, repository).get_info(cookie_jar, session)
        expect(result).to eql(other_ways_data)
      end
    end
  end
end
