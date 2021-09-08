require "spec_helper"
require "rails_helper"
require "display/rp/service_list_data_correlator"
require "display/rp_display_data"
require "display/rp_display_repository"

module Display
  module Rp
    describe ServiceListDataCorrelator, skip_before: true do
      let(:transaction_a_name) { "Transaction A" }
      let(:transaction_2_name) { "Transaction 2" }
      let(:transaction_3_name) { "Transaction 3" }
      let(:transaction_4_name) { "Transaction 4" }

      let(:homepage) { "http://transaction-a.com" }
      let(:homepage_2) { "http://transaction-2.com" }
      let(:homepage_3) { "http://transaction-3.com" }
      let(:homepage_4) { "http://transaction-4.com" }

      let(:entityId) { "http://transaction-a.com/entityId" }
      let(:entityId_2) { "http://transaction-2.com/entityId" }
      let(:entityId_3) { "http://transaction-3.com/entityId" }
      let(:entityId_4) { "http://transaction-4.com/entityId" }

      let(:public_simple_id) { "test-rp" }
      let(:public_simple_id_2) { "test-rp-2" }
      let(:public_simple_id_3) { "test-rp-3" }
      let(:public_simple_id_4) { "test-rp-4" }

      let(:public_simple_id_loa) { [LevelOfAssurance::LOA1] }
      let(:public_simple_id_2_loa) { [LevelOfAssurance::LOA1] }
      let(:public_simple_id_3_loa) { [LevelOfAssurance::LOA1, LevelOfAssurance::LOA2] }
      let(:public_simple_id_4_loa) { [LevelOfAssurance::LOA2] }

      let(:expected_public_simple_id_loa) { LevelOfAssurance::LOA1 }
      let(:expected_public_simple_id_2_loa) { LevelOfAssurance::LOA1 }
      let(:expected_public_simple_id_3_loa) { LevelOfAssurance::LOA1 }
      let(:expected_public_simple_id_4_loa) { LevelOfAssurance::LOA2 }

      let(:public_taxon) { "Taxon 1" }
      let(:public_taxon_2) { "Taxon 2" }
      let(:public_taxon_3) { "Taxon 3" }
      let(:public_taxon_4) { "Taxon 4" }

      let(:rp_display_repository) { instance_double("Display::RpDisplayRepository") }

      let(:service_list_data_correlator) do
        ServiceListDataCorrelator.new(rp_display_repository)
      end

      let(:display_data_1) do
        instance_double("Display::RpDisplayData", name: transaction_a_name, taxon: public_taxon)
      end
      let(:display_data_2) do
        instance_double("Display::RpDisplayData", name: transaction_2_name, taxon: public_taxon_2)
      end
      let(:display_data_3) do
        instance_double("Display::RpDisplayData", name: transaction_3_name, taxon: public_taxon_3)
      end
      let(:display_data_4) do
        instance_double("Display::RpDisplayData", name: transaction_4_name, taxon: public_taxon_4)
      end

      it "returns the transactions with display name, homepage, loa and simpleId" do
        expect(rp_display_repository).to receive(:get_translations).with(public_simple_id).and_return(display_data_1)
        expect(rp_display_repository).to receive(:get_translations).with(public_simple_id_2).and_return(display_data_2)
        expect(rp_display_repository).to receive(:get_translations).with(public_simple_id_3).and_return(display_data_3)
        expect(rp_display_repository).to receive(:get_translations).with(public_simple_id_4).and_return(display_data_4)
        transaction_data = [
          {
            simpleId: public_simple_id,
            serviceHomepage: homepage,
            loaList: public_simple_id_loa,
            entityId: entityId,
          },
          {
            simpleId: public_simple_id_2,
            serviceHomepage: homepage_2,
            loaList: public_simple_id_2_loa,
            entityId: entityId_2,
          },
          {
            simpleId: public_simple_id_3,
            serviceHomepage: homepage_3,
            loaList: public_simple_id_3_loa,
            entityId: entityId_3,
          },
          {
            simpleId: public_simple_id_4,
            serviceHomepage: homepage_4,
            loaList: public_simple_id_4_loa,
            entityId: entityId_4,
          },
        ]
        correlator = ServiceListDataCorrelator.new(rp_display_repository)
        actual_result = correlator.correlate(transaction_data)
        expected_result = [
          ServiceListDataCorrelator::Transaction.new(
            transaction_a_name,
            expected_public_simple_id_loa,
            public_taxon,
            entityId,
            public_simple_id,
          ),
          ServiceListDataCorrelator::Transaction.new(
            transaction_2_name,
            expected_public_simple_id_2_loa,
            public_taxon_2,
            entityId_2,
            public_simple_id_2,
          ),
          ServiceListDataCorrelator::Transaction.new(
            transaction_3_name,
            expected_public_simple_id_3_loa,
            public_taxon_3,
            entityId_3,
            public_simple_id_3,
          ),
          ServiceListDataCorrelator::Transaction.new(
            transaction_4_name,
            expected_public_simple_id_4_loa,
            public_taxon_4,
            entityId_4,
            public_simple_id_4,
          ),
        ]
        expect(actual_result).to eq expected_result
      end

      it "should return transactions with an empty list when the transactions property is absent" do
        transaction_data = {}
        expect(service_list_data_correlator.correlate(transaction_data))
          .to eq([])
      end
    end
  end
end
