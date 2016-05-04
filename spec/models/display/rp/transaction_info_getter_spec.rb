require 'spec_helper'
require 'models/display/rp/transaction_info_getter'
require 'rails_helper'

module Display
  module Rp
    describe TransactionInfoGetter do
      let(:session_proxy) { double(:session_proxy) }
      let(:session) { { transaction_simple_id: 'simple-id' } }
      let(:repository) { double(:repository) }

      it 'should return the transaction info from session' do
        simple_id = 'simple-id'
        other_ways_data = OpenStruct.new(other_ways_description: 'Other ways description', other_ways_text: 'Other ways text')
        expect(repository).to receive(:fetch).with(simple_id).and_return(other_ways_data)
        result = TransactionInfoGetter.new(session_proxy, repository).get_info(session)
        expect(result).to eql(other_ways_data)
      end

      it "should raise StandardError if transaction simple id isn't in session" do
        expect {
          TransactionInfoGetter.new(session_proxy, repository).get_info({})
        }.to raise_error(StandardError, 'No transaction simple id in session')
      end
    end
  end
end
