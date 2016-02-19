require 'spec_helper'
require 'models/display/rp/display_data_correlator'

module Display
  module Rp
    describe DisplayDataCorrelator do
      let(:transaction_a_name) { 'Transaction A' }
      let(:transaction_b_name) { 'Private Transaction B'}
      let(:translator) { double(:translator) }
      let(:homepage) { 'http://transaction-a.com' }
      let(:public_simple_id) { 'test-rp' }
      let(:private_simple_id) { 'some-simple-id' }

      before(:each) do
        allow(translator).to receive(:translate).with('rps.test-rp.name', raise: true).and_return(transaction_a_name)
        allow(translator).to receive(:translate).with('rps.some-simple-id.name', raise: true).and_return(transaction_b_name)
      end

      it 'takes a list of transaction data and a translator with knowledge of RPs and return a list of transactions to display' do
        transaction_data = {
            'public' => [{ 'simpleId' => public_simple_id, 'homepage' => homepage }],
            'private' => [{ 'simpleId' => private_simple_id }]
        }
        actual_result = DisplayDataCorrelator.new.correlate(transaction_data, translator)
        expected_result = DisplayDataCorrelator::Transactions.new(
          [DisplayDataCorrelator::Transaction.new(transaction_a_name, homepage)],
          [DisplayDataCorrelator::Transaction.new(transaction_b_name)])
        expect(actual_result).to eq expected_result
      end

      it 'errors when the public property is absent' do
        transaction_data = { 'private' => [{ 'simpleId' => private_simple_id }] }
        expect {
          DisplayDataCorrelator.new.correlate(transaction_data, translator)
        }.to raise_error KeyError
      end

      it 'errors when the private property is absent' do
        transaction_data = { 'public' => [{ 'simpleId' => public_simple_id, 'homepage' => homepage }] }
        expect {
          DisplayDataCorrelator.new.correlate(transaction_data, translator)
        }.to raise_error KeyError
      end

      it 'errors when public simpleId is missing' do
        transaction_data = { 'public' => [{ 'homepage' => homepage }], 'private' => [{'simpleId' => private_simple_id}] }
        expect {
          DisplayDataCorrelator.new.correlate(transaction_data, translator)
        }.to raise_error KeyError
      end

      it 'errors when private simpleId is missing' do
        transaction_data = { 'public' => [{ 'simpleId' => public_simple_id, 'homepage' => homepage }], 'private' => [{}] }
        expect {
          DisplayDataCorrelator.new.correlate(transaction_data, translator)
        }.to raise_error KeyError
      end

      it 'errors when homepage is missing' do
        transaction_data = { 'public' => [{ 'simpleId' => public_simple_id }], 'private' => [{'simpleId' => private_simple_id}] }
        expect {
          DisplayDataCorrelator.new.correlate(transaction_data, translator)
        }.to raise_error KeyError
      end
    end
  end
end
