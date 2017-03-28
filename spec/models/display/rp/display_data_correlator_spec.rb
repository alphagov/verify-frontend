require 'spec_helper'
require 'models/display/rp/display_data_correlator'

module Display
  module Rp
    describe DisplayDataCorrelator do
      let(:transaction_a_name) { 'Transaction A' }
      let(:transaction_2_name) { 'Transaction 2' }
      let(:transaction_3_name) { 'Transaction 3' }
      let(:transaction_4_name) { 'Transaction 4' }
      let(:transaction_b_name) { 'Private Transaction B' }
      let(:translator) { double(:translator) }
      let(:homepage) { 'http://transaction-a.com' }
      let(:public_simple_id) { 'test-rp' }
      let(:public_simple_id_2) { 'test-rp-2' }
      let(:public_simple_id_3) { 'test-rp-3' }
      let(:public_simple_id_4) { 'test-rp-4' }
      let(:private_simple_id) { 'some-simple-id' }
      let(:display_data_correlator) {
        DisplayDataCorrelator.new(translator, [public_simple_id], [private_simple_id])
      }

      before(:each) do
        allow(translator).to receive(:translate).with('rps.test-rp.name').and_return(transaction_a_name)
        allow(translator).to receive(:translate).with('rps.test-rp-2.name').and_return(transaction_2_name)
        allow(translator).to receive(:translate).with('rps.test-rp-3.name').and_return(transaction_3_name)
        allow(translator).to receive(:translate).with('rps.test-rp-4.name').and_return(transaction_4_name)
        allow(translator).to receive(:translate).with('rps.some-simple-id.name').and_return(transaction_b_name)
      end

      it 'returns the transactions with display name and homepage in the order listed in the relying_parties_config' do
        transaction_data = {
            'transactions' => [
                { 'simpleId' => public_simple_id, 'homepage' => homepage },
                { 'simpleId' => public_simple_id_2, 'homepage' => homepage },
                { 'simpleId' => public_simple_id_3, 'homepage' => homepage },
                { 'simpleId' => public_simple_id_4, 'homepage' => homepage },
            ]
        }
        correlator = DisplayDataCorrelator.new(translator, [public_simple_id_4, public_simple_id_2, public_simple_id, public_simple_id_3], [])
        actual_result = correlator.correlate(transaction_data)
        expected_result = DisplayDataCorrelator::Transactions.new(
          [
            DisplayDataCorrelator::Transaction.new(transaction_4_name, homepage),
            DisplayDataCorrelator::Transaction.new(transaction_2_name, homepage),
            DisplayDataCorrelator::Transaction.new(transaction_a_name, homepage),
            DisplayDataCorrelator::Transaction.new(transaction_3_name, homepage)
          ],
          [])
        expect(actual_result).to eq expected_result
      end

      it 'translates and filters the transactions according to the relying_parties config' do
        transaction_data = {
          'transactions' => [
            { 'simpleId' => public_simple_id, 'homepage' => homepage },
            { 'simpleId' => private_simple_id }
          ]
        }
        actual_result = display_data_correlator.correlate(transaction_data)
        expected_result = DisplayDataCorrelator::Transactions.new(
          [DisplayDataCorrelator::Transaction.new(transaction_a_name, homepage)],
          [DisplayDataCorrelator::Transaction.new(transaction_b_name)])
        expect(actual_result).to eq expected_result
      end

      it 'errors when the transactions property is absent' do
        transaction_data = {}
        expect {
          display_data_correlator.correlate(transaction_data)
        }.to raise_error KeyError
      end

      it 'errors when homepage is missing' do
        transaction_data = { 'transactions' => [{ 'simpleId' => public_simple_id }, { 'simpleId' => private_simple_id }] }
        expect {
          display_data_correlator.correlate(transaction_data)
        }.to raise_error KeyError
      end
    end
  end
end
