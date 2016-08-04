require 'spec_helper'
require 'models/display/rp/transaction_lister'

module Display
  module Rp
    describe TransactionLister do
      let(:session) { double(:session) }

      it 'should create a list of transactions with name and homepage if public' do
        transactions_proxy = double(:transactions_proxy)
        correlator = double(:correlator)

        transactions_list = double(:result_list)
        correlated_data = double(:correlated_data)

        expect(transactions_proxy).to receive(:transactions).with(session).and_return(transactions_list)
        expect(correlator).to receive(:correlate).with(transactions_list).and_return(correlated_data)

        list = TransactionLister.new(transactions_proxy, correlator).list(session)

        expect(list).to eq correlated_data
      end

      it 'should create a empty list of transactions when an error has been raised' do
        transactions_proxy = double(:transactions_proxy)
        correlator = double(:correlator)

        transactions_list = double(:result_list)
        correlated_data = double(:correlated_data)

        expect(transactions_proxy).to receive(:transactions).with(session).and_return(transactions_list)
        expect(correlator).to receive(:correlate).with(transactions_list).and_return(correlated_data)

        list = TransactionLister.new(transactions_proxy, correlator).list(session)

        expect(list).to eq correlated_data
      end
    end
  end
end
