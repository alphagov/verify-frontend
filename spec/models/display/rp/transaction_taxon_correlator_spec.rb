require 'spec_helper'
require 'transaction_response'
require 'display/rp/transaction_taxon_correlator'
require 'display/rp_display_repository'
require 'display/rp_display_data'
require 'transaction_list'

module Display
  module Rp
    describe TransactionTaxonCorrelator do
      let(:simple_id_1) { 'test-rp-1' }
      let(:simple_id_2) { 'test-rp-2' }
      let(:simple_id_a) { 'test-rp-a' }
      let(:simple_id_b) { 'test-rp-b' }

      let(:transaction_1_name) { 'Test RP 1' }
      let(:transaction_2_name) { 'Test RP 2' }
      let(:transaction_a_name) { 'Test RP a' }
      let(:transaction_b_name) { 'Test RP B' }

      let(:homepage) { 'https://example-homepage/' }

      let(:taxon_benefits) { 'Benefits' }
      let(:taxon_working_jobs_and_pensions) { 'Working, jobs and pensions' }
      let(:taxon_other_services) { 'Other services' }
      let(:repository) { instance_double(Display::RpDisplayRepository) }
      let(:display_data_1) { instance_double("Display::RpDisplayData", "1", name: transaction_1_name) }
      let(:display_data_2) { instance_double("Display::RpDisplayData", "2", name: transaction_2_name) }
      let(:display_data_a) { instance_double("Display::RpDisplayData", "a", name: transaction_a_name) }
      let(:display_data_b) { instance_double("Display::RpDisplayData", "b", name: transaction_b_name) }
      let(:transaction_1) { instance_double("TransactionResponse", "1", simple_id: simple_id_1, homepage: homepage, valid?: true) }
      let(:transaction_2) { instance_double("TransactionResponse", "2", simple_id: simple_id_2, homepage: homepage, valid?: true) }
      let(:transaction_a) { instance_double("TransactionResponse", "a", simple_id: simple_id_a, homepage: homepage, valid?: true) }
      let(:transaction_b) { instance_double("TransactionResponse", "b", simple_id: simple_id_b, homepage: homepage, valid?: true) }
      let(:config_proxy) { double(:config_proxy) }

      before(:each) do
        allow(TransactionList).to receive(:rp_display_repository).and_return(repository)
        allow(TransactionList).to receive(:rps_with_homepage).and_return([simple_id_1, simple_id_2, simple_id_a, simple_id_b])
        allow(TransactionList).to receive(:rps_without_homepage).and_return([])
        allow(Taxon).to receive(:default_taxon).and_return(taxon_other_services)
        @correlator = TransactionTaxonCorrelator.new
      end

      it 'should return an empty list when there are no transactions' do
        actual_result = @correlator.correlate([])
        expect(actual_result).to eq []
      end

      it 'should group transactions by taxon' do
        transaction_data = [
          transaction_1, transaction_2, transaction_a, transaction_b
        ]

        expect(display_data_1).to receive(:taxon).and_return(taxon_benefits)
        expect(display_data_2).to receive(:taxon).and_return(taxon_working_jobs_and_pensions)
        expect(display_data_a).to receive(:taxon).and_return(taxon_benefits)
        expect(display_data_b).to receive(:taxon).and_return(taxon_working_jobs_and_pensions)

        expect(repository).to receive(:get_translations).with(simple_id_1).and_return display_data_1
        expect(repository).to receive(:get_translations).with(simple_id_2).and_return display_data_2
        expect(repository).to receive(:get_translations).with(simple_id_a).and_return display_data_a
        expect(repository).to receive(:get_translations).with(simple_id_b).and_return display_data_b

        actual_result = @correlator.correlate(transaction_data)

        expected_result = [
            Taxon.new(
              taxon_benefits,
              [
                  DecoratedTransaction.new(display_data_1, transaction_1),
                  DecoratedTransaction.new(display_data_a, transaction_a),
              ]
            ),
            Taxon.new(
              taxon_working_jobs_and_pensions,
              [
                  DecoratedTransaction.new(display_data_2, transaction_2),
                  DecoratedTransaction.new(display_data_b, transaction_b),
              ]
            )
        ]
        expect(actual_result).to eq expected_result
      end

      it 'should group transactions without a taxon as Other services' do
        transaction_data = [transaction_1]

        expect(repository).to receive(:get_translations).with(simple_id_1).and_return display_data_1
        expect(display_data_1).to receive(:taxon).and_return(taxon_other_services)

        actual_result = @correlator.correlate(transaction_data)

        expected_result = [
            Taxon.new(
              taxon_other_services,
              [
                  DecoratedTransaction.new(display_data_1, transaction_1),
              ]
            )
        ]
        expect(actual_result).to eq expected_result
      end

      it 'should create an other services taxon for transactions without a homepage if it does not already exist' do
        transaction_data = [transaction_1]
        expect(repository).to receive(:get_translations).with(simple_id_1).and_return display_data_1
        expect(transaction_1).to receive(:homepage).and_return(nil)
        expect(display_data_1).to receive(:default_taxon).and_return(taxon_other_services)

        actual_result = @correlator.correlate(transaction_data)

        expected_result = [
            Taxon.new(
              taxon_other_services,
              [
                  DecoratedTransaction.new(display_data_1, transaction_1),
              ]
            )
        ]
        expect(actual_result).to eq expected_result
      end

      it 'should add transactions without a homepage to the other services taxon if the taxon already exists' do
        transaction_without_homepage = instance_double("TransactionResponse",
                                                       "2",
                                                       simple_id: simple_id_2,
                                                       homepage: nil,
                                                       valid?: true)
        transaction_data = [
          transaction_1,
          transaction_without_homepage
        ]

        expect(repository).to receive(:get_translations).with(simple_id_1).and_return display_data_1
        expect(repository).to receive(:get_translations).with(simple_id_2).and_return display_data_2
        expect(display_data_1).to receive(:taxon).and_return(taxon_other_services)
        expect(display_data_2).to receive(:default_taxon).and_return(taxon_other_services)

        actual_result = @correlator.correlate(transaction_data)

        expected_result = [
            Taxon.new(
              taxon_other_services,
              [
                  DecoratedTransaction.new(display_data_1, transaction_1),
                  DecoratedTransaction.new(display_data_2, transaction_without_homepage),
              ]
            )
        ]
        expect(actual_result).to eq expected_result
      end

      it 'should sort the taxons alphabetically, with Other services last.' do
        transaction_data = [
          transaction_2,
          transaction_a,
          transaction_1,
        ]

        expect(display_data_1).to receive(:taxon).and_return(taxon_other_services)
        expect(display_data_2).to receive(:taxon).and_return(taxon_working_jobs_and_pensions)
        expect(display_data_a).to receive(:taxon).and_return(taxon_benefits)
        expect(repository).to receive(:get_translations).with(simple_id_1).and_return display_data_1
        expect(repository).to receive(:get_translations).with(simple_id_2).and_return display_data_2
        expect(repository).to receive(:get_translations).with(simple_id_a).and_return display_data_a

        actual_result = @correlator.correlate(transaction_data)

        expected_result = [
            Taxon.new(
              taxon_benefits,
              [
                  DecoratedTransaction.new(display_data_a, transaction_a),
              ]
            ),
            Taxon.new(
              taxon_working_jobs_and_pensions,
              [
                  DecoratedTransaction.new(display_data_2, transaction_2),
              ]
            ),
            Taxon.new(
              taxon_other_services,
              [
                  DecoratedTransaction.new(display_data_1, transaction_1),
              ]
            ),
        ]
        expect(actual_result).to eq expected_result
      end

      it 'should sort the transactions within a taxon alphabetically' do
        transaction_data = [
          transaction_2,
          transaction_a,
          transaction_b,
          transaction_1,
        ]

        expect(repository).to receive(:get_translations).with(simple_id_1).and_return display_data_1
        expect(repository).to receive(:get_translations).with(simple_id_2).and_return display_data_2
        expect(repository).to receive(:get_translations).with(simple_id_a).and_return display_data_a
        expect(repository).to receive(:get_translations).with(simple_id_b).and_return display_data_b
        expect(display_data_1).to receive(:taxon).and_return(taxon_benefits)
        expect(display_data_2).to receive(:taxon).and_return(taxon_benefits)
        expect(display_data_a).to receive(:taxon).and_return(taxon_benefits)
        expect(display_data_b).to receive(:taxon).and_return(taxon_benefits)

        actual_result = @correlator.correlate(transaction_data)

        expected_results = [
            Taxon.new(
              taxon_benefits,
              [
                  DecoratedTransaction.new(display_data_1, transaction_1),
                  DecoratedTransaction.new(display_data_2, transaction_2),
                  DecoratedTransaction.new(display_data_a, transaction_a),
                  DecoratedTransaction.new(display_data_b, transaction_b),
              ]
            )
        ]

        expect(actual_result).to eq expected_results
      end

      it 'should not show transactions which are not listed in the enabled list' do
        transaction_data = [
          transaction_1,
          transaction_2,
          transaction_a,
        ]

        expect(repository).to receive(:get_translations).with(simple_id_1).and_return display_data_1
        expect(repository).to receive(:get_translations).with(simple_id_2).and_return display_data_2
        expect(repository).to_not receive(:get_translations).with(simple_id_a)

        expect(display_data_1).to receive(:taxon).and_return(taxon_benefits)
        expect(display_data_2).to receive(:default_taxon).and_return(taxon_other_services)

        expect(TransactionList).to receive(:rps_with_homepage).and_return([simple_id_1]).twice
        expect(TransactionList).to receive(:rps_without_homepage).and_return([simple_id_2])

        test_correlator = TransactionTaxonCorrelator.new
        actual_result = test_correlator.correlate(transaction_data)

        expected_results = [
            Taxon.new(
              taxon_benefits,
              [
                  DecoratedTransaction.new(display_data_1, transaction_1),
              ]
            ),
            Taxon.new(
              taxon_other_services,
              [
                  DecoratedTransaction.new(display_data_2, transaction_2),
              ]
            )
        ]
        expect(actual_result).to eq expected_results
      end

      it 'will return any empty list if any transaction is invalid' do
        transaction_data = [
          transaction_1,
          transaction_2,
          transaction_a,
          transaction_b,
        ]
        logger = double(:logger)
        error_messages = "transaction_1_error_messages"
        expect(TransactionList).to receive(:logger).and_return logger
        expect(logger).to receive(:error).with("#{simple_id_1}: #{error_messages}")
        expect(transaction_1).to receive(:valid?).and_return(false)
        expect(transaction_1).to receive(:error_messages).and_return(error_messages)
        expect(TransactionTaxonCorrelator.new.correlate(transaction_data)).to eq []
      end
    end
  end
end
