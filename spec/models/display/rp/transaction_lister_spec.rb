require 'spec_helper'
require 'models/display/rp/transaction_lister'

module Display
  module Rp
    describe TransactionLister do
      it 'should create a list of transactions with name and homepage if public' do
        proxy = double(:proxy)
        correlator = double(:correlator)

        transactions_list = double(:result_list)
        correlated_data = double(:correlated_data)
        translator = double(:translator)

        expect(proxy).to receive(:transactions).and_return(transactions_list)
        expect(correlator).to receive(:correlate).with(transactions_list, translator).and_return(correlated_data)

        list = TransactionLister.new(proxy, correlator).list(translator)

        expect(list).to eq correlated_data
      end

      it 'should create a empty list of transactions when an error has been raised' do
        proxy = double(:proxy)
        correlator = double(:correlator)

        transactions_list = double(:result_list)
        correlated_data = double(:correlated_data)
        translator = double(:translator)

        expect(proxy).to receive(:transactions).and_return(transactions_list)
        expect(correlator).to receive(:correlate).with(transactions_list, translator).and_return(correlated_data)

        list = TransactionLister.new(proxy, correlator).list(translator)

        expect(list).to eq correlated_data
      end
    end
  end
end
