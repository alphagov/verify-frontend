require 'spec_helper'
require 'rails_helper'
require 'models/display/rp/service_list_data_correlator'

module Display
  module Rp
    describe ServiceListDataCorrelator do
      let(:transaction_a_name) { 'Transaction A' }
      let(:transaction_2_name) { 'Transaction 2' }
      let(:transaction_3_name) { 'Transaction 3' }
      let(:transaction_4_name) { 'Transaction 4' }

      let(:translator) { double(:translator) }
      let(:homepage) { 'http://transaction-a.com' }
      let(:homepage_2) { 'http://transaction-2.com' }
      let(:homepage_3) { 'http://transaction-3.com' }
      let(:homepage_4) { 'http://transaction-4.com' }

      let(:entityId) { 'http://transaction-a.com/entityId' }
      let(:entityId_2) { 'http://transaction-2.com/entityId' }
      let(:entityId_3) { 'http://transaction-3.com/entityId' }
      let(:entityId_4) { 'http://transaction-4.com/entityId' }

      let(:public_simple_id) { 'test-rp' }
      let(:public_simple_id_2) { 'test-rp-2' }
      let(:public_simple_id_3) { 'test-rp-3' }
      let(:public_simple_id_4) { 'test-rp-4' }

      let(:public_simple_id_loa) { ['LEVEL_1'] }
      let(:public_simple_id_2_loa) { ['LEVEL_1'] }
      let(:public_simple_id_3_loa) { %w'LEVEL_1 LEVEL_2' }
      let(:public_simple_id_4_loa) { ['LEVEL_2'] }

      let(:expected_public_simple_id_loa) { 'LEVEL_1' }
      let(:expected_public_simple_id_2_loa) { 'LEVEL_1' }
      let(:expected_public_simple_id_3_loa) { 'LEVEL_1' }
      let(:expected_public_simple_id_4_loa) { 'LEVEL_2' }

      let(:public_taxon) { 'Taxon 1' }
      let(:public_taxon_2) { 'Taxon 2' }
      let(:public_taxon_3) { 'Taxon 3' }
      let(:public_taxon_4) { 'Taxon 4' }

      let(:service_list_data_correlator) do
        ServiceListDataCorrelator.new(translator, [public_simple_id])
      end

      before(:each) do
        allow(translator)
          .to receive(:translate)
            .with('rps.test-rp.name')
            .and_return(transaction_a_name)
        allow(translator)
          .to receive(:translate)
            .with('rps.test-rp-2.name')
            .and_return(transaction_2_name)
        allow(translator)
          .to receive(:translate)
            .with('rps.test-rp-3.name')
            .and_return(transaction_3_name)
        allow(translator)
          .to receive(:translate)
            .with('rps.test-rp-4.name')
            .and_return(transaction_4_name)

        allow(translator)
          .to receive(:translate)
            .with('rps.test-rp.taxon_name')
            .and_return(public_taxon)
        allow(translator)
          .to receive(:translate)
            .with('rps.test-rp-2.taxon_name')
            .and_return(public_taxon_2)
        allow(translator)
          .to receive(:translate)
            .with('rps.test-rp-3.taxon_name')
            .and_return(public_taxon_3)
        allow(translator)
          .to receive(:translate)
            .with('rps.test-rp-4.taxon_name')
            .and_return(public_taxon_4)
      end

      it 'returns the transactions with display name, homepage, loa and simpleId' do
        transaction_data = [
          {
              'simpleId' => public_simple_id,
              'serviceHomepage' => homepage,
              'loaList' => public_simple_id_loa,
              'entityId' => entityId
          },
          {
              'simpleId' => public_simple_id_2,
              'serviceHomepage' => homepage_2,
              'loaList' => public_simple_id_2_loa,
              'entityId' => entityId_2
          },
          {
              'simpleId' => public_simple_id_3,
              'serviceHomepage' => homepage_3,
              'loaList' => public_simple_id_3_loa,
              'entityId' => entityId_3
          },
          {
              'simpleId' => public_simple_id_4,
              'serviceHomepage' => homepage_4,
              'loaList' => public_simple_id_4_loa,
              'entityId' => entityId_4
          },
        ]
        correlator = ServiceListDataCorrelator.new(
          translator,
          [
            public_simple_id_4,
            public_simple_id_2,
            public_simple_id,
            public_simple_id_3
          ]
        )
        actual_result = correlator.correlate(transaction_data)
        expected_result = [
          ServiceListDataCorrelator::Transaction.new(
            transaction_4_name,
            expected_public_simple_id_4_loa,
            public_taxon_4,
            entityId_4
          ),
          ServiceListDataCorrelator::Transaction.new(
            transaction_2_name,
            expected_public_simple_id_2_loa,
            public_taxon_2,
            entityId_2
          ),
          ServiceListDataCorrelator::Transaction.new(
            transaction_a_name,
            expected_public_simple_id_loa,
            public_taxon,
            entityId
          ),
          ServiceListDataCorrelator::Transaction.new(
            transaction_3_name,
            expected_public_simple_id_3_loa,
            public_taxon_3,
            entityId_3
          )
        ]
        expect(actual_result).to eq expected_result
      end

      it 'should return transactions with an empty list when the transactions property is absent' do
        transaction_data = {}
        expect(service_list_data_correlator.correlate(transaction_data))
          .to eq([])
      end
    end
  end
end
