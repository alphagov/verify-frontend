require 'spec_helper'
require 'rails_helper'
require 'models/display/rp/transaction_taxon_correlator'

module Display
  module Rp
    describe TransactionTaxonCorrelator do
      let(:translator) { double(:translator) }

      let(:simple_id_1) { 'test-rp-1' }
      let(:simple_id_2) { 'test-rp-2' }
      let(:simple_id_a) { 'test-rp-a' }
      let(:simple_id_b) { 'test-rp-b' }

      let(:transaction_1_name) { 'Test RP 1' }
      let(:transaction_2_name) { 'Test RP 2' }
      let(:transaction_a_name) { 'Test RP a' }
      let(:transaction_b_name) { 'Test RP B' }

      let(:homepage) { 'https://example-homepage/' }

      let(:loa_list) { ['LEVEL_2'] }

      let(:taxon_benefits) { 'Benefits' }
      let(:taxon_working_jobs_and_pensions) { 'Working, jobs and pensions' }
      let(:taxon_other_services) { 'Other services' }

      before(:each) do
        allow(translator).to receive(:translate).with('rps.test-rp-1.name').and_return(transaction_1_name)
        allow(translator).to receive(:translate).with('rps.test-rp-2.name').and_return(transaction_2_name)
        allow(translator).to receive(:translate).with('rps.test-rp-a.name').and_return(transaction_a_name)
        allow(translator).to receive(:translate).with('rps.test-rp-b.name').and_return(transaction_b_name)

        allow(translator).to receive(:translate).with('errors.transaction_list.other_services').and_return(taxon_other_services)

        @correlator = TransactionTaxonCorrelator.new(translator)
      end

      it 'should return an empty list when there are no transactions' do
        actual_result = @correlator.correlate({})
        expect(actual_result).to eq []
      end

      it 'should group transactions by taxon' do
        transaction_data = [
            { 'simpleId' => simple_id_1, 'serviceHomepage' => homepage, 'loaList' => loa_list },
            { 'simpleId' => simple_id_2, 'serviceHomepage' => homepage, 'loaList' => loa_list },
            { 'simpleId' => simple_id_a, 'serviceHomepage' => homepage, 'loaList' => loa_list },
            { 'simpleId' => simple_id_b, 'serviceHomepage' => homepage, 'loaList' => loa_list },
        ]
        allow(translator).to receive(:translate).with('rps.test-rp-1.taxon_name').and_return(taxon_benefits)
        allow(translator).to receive(:translate).with('rps.test-rp-2.taxon_name').and_return(taxon_working_jobs_and_pensions)
        allow(translator).to receive(:translate).with('rps.test-rp-a.taxon_name').and_return(taxon_benefits)
        allow(translator).to receive(:translate).with('rps.test-rp-b.taxon_name').and_return(taxon_working_jobs_and_pensions)

        actual_result = @correlator.correlate(transaction_data)

        expected_result = [
            TransactionTaxonCorrelator::Taxon.new(
              taxon_benefits,
              [
                  TransactionTaxonCorrelator::Transaction.new(transaction_1_name, taxon_benefits, homepage, loa_list),
                  TransactionTaxonCorrelator::Transaction.new(transaction_a_name, taxon_benefits, homepage, loa_list)
              ]
            ),
            TransactionTaxonCorrelator::Taxon.new(
              taxon_working_jobs_and_pensions,
              [
                  TransactionTaxonCorrelator::Transaction.new(transaction_2_name, taxon_working_jobs_and_pensions, homepage, loa_list),
                  TransactionTaxonCorrelator::Transaction.new(transaction_b_name, taxon_working_jobs_and_pensions, homepage, loa_list)
              ]
            )
        ]
        expect(actual_result).to eq expected_result
      end

      it 'should group transactions without a taxon as Other services' do
        allow(translator).to receive(:translate)
                                 .with('rps.test-rp-1.taxon_name')
                                 .and_raise(Display::FederationTranslator::TranslationError.new)
        transaction_data = [
            { 'simpleId' => simple_id_1, 'serviceHomepage' => homepage, 'loaList' => loa_list }
        ]
        actual_result = @correlator.correlate(transaction_data)

        expected_result = [
            TransactionTaxonCorrelator::Taxon.new(
              taxon_other_services,
              [
                  TransactionTaxonCorrelator::Transaction.new(transaction_1_name, taxon_other_services, homepage, loa_list),
              ]
            )
        ]
        expect(actual_result).to eq expected_result
      end

      it 'should create an other services taxon for transactions without a homepage if it does not already exist' do
        allow(translator).to receive(:translate).with('rps.test-rp-1.taxon_name').and_return(taxon_benefits)
        transaction_data = [
            { 'simpleId' => simple_id_1, 'loaList' => loa_list }
        ]
        actual_result = @correlator.correlate(transaction_data)

        expected_result = [
            TransactionTaxonCorrelator::Taxon.new(
              taxon_other_services,
              [
                  TransactionTaxonCorrelator::Transaction.new(transaction_1_name, taxon_other_services, nil, loa_list),
              ]
            )
        ]
        expect(actual_result).to eq expected_result
      end

      it 'should add transactions without a homepage to the other services taxon if the taxon already exists' do
        allow(translator).to receive(:translate).with('rps.test-rp-1.taxon_name').and_return(taxon_other_services)
        allow(translator).to receive(:translate).with('rps.test-rp-2.taxon_name').and_return(taxon_benefits)
        transaction_data = [
            { 'simpleId' => simple_id_1, 'serviceHomepage' => homepage, 'loaList' => loa_list },
            { 'simpleId' => simple_id_2, 'loaList' => loa_list }
        ]
        actual_result = @correlator.correlate(transaction_data)

        expected_result = [
            TransactionTaxonCorrelator::Taxon.new(
              taxon_other_services,
              [
                  TransactionTaxonCorrelator::Transaction.new(transaction_1_name, taxon_other_services, homepage, loa_list),
                  TransactionTaxonCorrelator::Transaction.new(transaction_2_name, taxon_other_services, nil, loa_list),
              ]
            )
        ]
        expect(actual_result).to eq expected_result
      end

      it 'should sort the taxons alphabetically, with Other services last.' do
        allow(translator).to receive(:translate).with('rps.test-rp-1.taxon_name').and_return(taxon_other_services)
        allow(translator).to receive(:translate).with('rps.test-rp-2.taxon_name').and_return(taxon_working_jobs_and_pensions)
        allow(translator).to receive(:translate).with('rps.test-rp-a.taxon_name').and_return(taxon_benefits)
        transaction_data = [
            { 'simpleId' => simple_id_2, 'serviceHomepage' => homepage, 'loaList' => loa_list },
            { 'simpleId' => simple_id_a, 'serviceHomepage' => homepage, 'loaList' => loa_list },
            { 'simpleId' => simple_id_1, 'serviceHomepage' => homepage, 'loaList' => loa_list },
        ]

        actual_result = @correlator.correlate(transaction_data)

        expected_result = [
            TransactionTaxonCorrelator::Taxon.new(
              taxon_benefits,
              [
                  TransactionTaxonCorrelator::Transaction.new(transaction_a_name, taxon_benefits, homepage, loa_list),
              ]
            ),
            TransactionTaxonCorrelator::Taxon.new(
              taxon_working_jobs_and_pensions,
              [
                  TransactionTaxonCorrelator::Transaction.new(transaction_2_name, taxon_working_jobs_and_pensions, homepage, loa_list),
              ]
            ),
            TransactionTaxonCorrelator::Taxon.new(
              taxon_other_services,
              [
                  TransactionTaxonCorrelator::Transaction.new(transaction_1_name, taxon_other_services, homepage, loa_list),
              ]
            ),
        ]
        expect(actual_result).to eq expected_result
      end

      it 'should sort the transactions within a taxon alphabetically' do
        allow(translator).to receive(:translate).with('rps.test-rp-1.taxon_name').and_return(taxon_benefits)
        allow(translator).to receive(:translate).with('rps.test-rp-2.taxon_name').and_return(taxon_benefits)
        allow(translator).to receive(:translate).with('rps.test-rp-a.taxon_name').and_return(taxon_benefits)
        allow(translator).to receive(:translate).with('rps.test-rp-b.taxon_name').and_return(taxon_benefits)
        transaction_data = [
            { 'simpleId' => simple_id_2, 'serviceHomepage' => homepage, 'loaList' => loa_list },
            { 'simpleId' => simple_id_b, 'serviceHomepage' => homepage, 'loaList' => loa_list },
            { 'simpleId' => simple_id_a, 'serviceHomepage' => homepage, 'loaList' => loa_list },
            { 'simpleId' => simple_id_1, 'serviceHomepage' => homepage, 'loaList' => loa_list }
        ]

        actual_result = @correlator.correlate(transaction_data)

        expected_results = [
            TransactionTaxonCorrelator::Taxon.new(
              taxon_benefits,
              [
                  TransactionTaxonCorrelator::Transaction.new(transaction_1_name, taxon_benefits, homepage, loa_list),
                  TransactionTaxonCorrelator::Transaction.new(transaction_2_name, taxon_benefits, homepage, loa_list),
                  TransactionTaxonCorrelator::Transaction.new(transaction_a_name, taxon_benefits, homepage, loa_list),
                  TransactionTaxonCorrelator::Transaction.new(transaction_b_name, taxon_benefits, homepage, loa_list)
              ]
            )
        ]

        expect(actual_result).to eq expected_results
      end
    end
  end
end
