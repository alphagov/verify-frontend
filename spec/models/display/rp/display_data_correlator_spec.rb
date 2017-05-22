require 'spec_helper'
require 'rails_helper'
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
      let(:homepage_2) { 'http://transaction-2.com' }
      let(:homepage_3) { 'http://transaction-3.com' }
      let(:homepage_4) { 'http://transaction-4.com' }

      let(:public_simple_id) { 'test-rp' }
      let(:public_simple_id_2) { 'test-rp-2' }
      let(:public_simple_id_3) { 'test-rp-3' }
      let(:public_simple_id_4) { 'test-rp-4' }
      let(:private_simple_id) { 'some-simple-id' }

      let(:public_simple_id_loa) { ['LEVEL_1'] }
      let(:public_simple_id_2_loa) { ['LEVEL_1'] }
      let(:public_simple_id_3_loa) { %w(LEVEL_1, LEVEL_2) }
      let(:public_simple_id_4_loa) { ['LEVEL_2'] }
      let(:private_simple_id_loa) { ['LEVEL_2'] }


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
                { 'simpleId' => public_simple_id, 'homepage' => homepage, 'loaList' => public_simple_id_loa },
                { 'simpleId' => public_simple_id_2, 'homepage' => homepage_2, 'loaList' => public_simple_id_2_loa },
                { 'simpleId' => public_simple_id_3, 'homepage' => homepage_3, 'loaList' => public_simple_id_3_loa },
                { 'simpleId' => public_simple_id_4, 'homepage' => homepage_4, 'loaList' => public_simple_id_4_loa },
            ]
        }
        correlator = DisplayDataCorrelator.new(translator, [public_simple_id_4, public_simple_id_2, public_simple_id, public_simple_id_3], [])
        actual_result = correlator.correlate(transaction_data)
        expected_result = DisplayDataCorrelator::Transactions.new(
          [
            DisplayDataCorrelator::Transaction.new(transaction_4_name, homepage_4, public_simple_id_4_loa),
            DisplayDataCorrelator::Transaction.new(transaction_2_name, homepage_2, public_simple_id_2_loa),
            DisplayDataCorrelator::Transaction.new(transaction_a_name, homepage, public_simple_id_loa),
            DisplayDataCorrelator::Transaction.new(transaction_3_name, homepage_3, public_simple_id_3_loa)
          ],
          [])
        expect(actual_result).to eq expected_result
      end

      it 'translates and filters the transactions according to the relying_parties config' do
        transaction_data = {
          'transactions' => [
            { 'simpleId' => public_simple_id, 'homepage' => homepage, 'loaList' => public_simple_id_loa },
            { 'simpleId' => private_simple_id, 'loaList' => private_simple_id_loa }
          ]
        }

        actual_result = display_data_correlator.correlate(transaction_data)
        expected_result = DisplayDataCorrelator::Transactions.new(
          [DisplayDataCorrelator::Transaction.new(transaction_a_name, homepage, public_simple_id_loa)],
          [DisplayDataCorrelator::Transaction.new(transaction_b_name, nil, private_simple_id_loa)])
        expect(actual_result).to eq expected_result
      end

      it 'should return transactions with two empty lists when the transactions property is absent' do
        transaction_data = {}
        expect(display_data_correlator.correlate(transaction_data)).to eq(DisplayDataCorrelator::Transactions.new([], []))
      end
    end
  end
end
