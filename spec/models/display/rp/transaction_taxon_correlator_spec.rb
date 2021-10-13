require "spec_helper"
require "rails_helper"
require "models/display/rp/transaction_taxon_correlator"
require "display/rp_display_repository"
require "display/rp_display_data"

module Display
  module Rp
    describe TransactionTaxonCorrelator, skip_before: true do
      let(:simple_id_1) { "test-rp-1" }
      let(:simple_id_2) { "test-rp-2" }
      let(:simple_id_a) { "test-rp-a" }
      let(:simple_id_b) { "test-rp-b" }

      let(:transaction_1_name) { "Test RP 1" }
      let(:transaction_2_name) { "Test RP 2" }
      let(:transaction_a_name) { "Test RP a" }
      let(:transaction_b_name) { "Test RP B" }

      let(:homepage) { "https://example-homepage/" }
      let(:headless_startpage) { "https://example-homepage/headless" }

      let(:loa_list) { %w(LEVEL_1) }

      let(:taxon_benefits) { "Benefits" }
      let(:taxon_working_jobs_and_pensions) { "Working, jobs and pensions" }
      let(:taxon_other_services) { "Other services" }
      let(:repository) { instance_double(Display::RpDisplayRepository) }
      let(:display_data_1) { instance_double(Display::RpDisplayData, name: transaction_1_name) }
      let(:display_data_2) { instance_double(Display::RpDisplayData, name: transaction_2_name) }
      let(:display_data_a) { instance_double(Display::RpDisplayData, name: transaction_a_name) }
      let(:display_data_b) { instance_double(Display::RpDisplayData, name: transaction_b_name) }

      before(:each) do
        @old_backend = I18n.backend
        I18n.backend = I18n::Backend::Simple.new
        I18n.backend.store_translations("hub.transaction_list.other_services", taxon_other_services)

        @correlator = TransactionTaxonCorrelator.new(repository, [simple_id_1, simple_id_2, simple_id_a, simple_id_b])
      end

      after(:each) do
        I18n.backend = @old_backend
      end

      it "should return an empty list when there are no transactions" do
        actual_result = @correlator.correlate({})
        expect(actual_result).to eq []
      end

      it "should group transactions by taxon" do
        transaction_data = [
          {
            "simpleId" => simple_id_1, "serviceHomepage" => homepage,
            "loaList" => loa_list, "headlessStartpage" => headless_startpage
          },
          {
            "simpleId" => simple_id_2, "serviceHomepage" => homepage,
            "loaList" => loa_list, "headlessStartpage" => headless_startpage
          },
          {
            "simpleId" => simple_id_a, "serviceHomepage" => homepage,
            "loaList" => loa_list, "headlessStartpage" => nil
          },
          {
            "simpleId" => simple_id_b, "serviceHomepage" => homepage,
            "loaList" => loa_list, "headlessStartpage" => nil
          },
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
          TransactionTaxonCorrelator::Taxon.new(
            taxon_benefits,
            [
              TransactionTaxonCorrelator::Transaction.new(
                transaction_1_name, taxon_benefits,
                homepage, loa_list, headless_startpage
              ),
              TransactionTaxonCorrelator::Transaction.new(
                transaction_a_name, taxon_benefits,
                homepage, loa_list, nil
              ),
            ],
          ),
          TransactionTaxonCorrelator::Taxon.new(
            taxon_working_jobs_and_pensions,
            [
              TransactionTaxonCorrelator::Transaction.new(
                transaction_2_name, taxon_working_jobs_and_pensions,
                homepage, loa_list, headless_startpage
              ),
              TransactionTaxonCorrelator::Transaction.new(
                transaction_b_name, taxon_working_jobs_and_pensions,
                homepage, loa_list, nil
              ),
            ],
          ),
        ]
        expect(actual_result).to eq expected_result
      end

      it "should group transactions without a taxon as Other services" do
        transaction_data = [
          {
            "simpleId" => simple_id_1, "serviceHomepage" => homepage,
            "loaList" => loa_list, "headlessStartpage" => headless_startpage
          },
        ]
        expect(repository).to receive(:get_translations).with(simple_id_1).and_return display_data_1
        expect(display_data_1).to receive(:taxon).and_return(taxon_other_services)

        actual_result = @correlator.correlate(transaction_data)

        expected_result = [
          TransactionTaxonCorrelator::Taxon.new(
            taxon_other_services,
            [
              TransactionTaxonCorrelator::Transaction.new(
                transaction_1_name, taxon_other_services,
                homepage, loa_list, headless_startpage
              ),
            ],
          ),
        ]
        expect(actual_result).to eq expected_result
      end

      it "should create an other services taxon for transactions without a homepage if it does not already exist" do
        transaction_data = [
          { "simpleId" => simple_id_1, "loaList" => loa_list },
        ]

        expect(repository).to receive(:get_translations).with(simple_id_1).and_return display_data_1
        expect(display_data_1).to_not receive(:taxon)

        actual_result = @correlator.correlate(transaction_data)

        expected_result = [
          TransactionTaxonCorrelator::Taxon.new(
            taxon_other_services,
            [
              TransactionTaxonCorrelator::Transaction.new(transaction_1_name, taxon_other_services, nil, loa_list),
            ],
          ),
        ]
        expect(actual_result).to eq expected_result
      end

      it "should add transactions without a homepage to the other services taxon if the taxon already exists" do
        I18n.backend.store_translations("en", "rps" => { "test-rp-1" => { "taxon_name" => taxon_other_services } })
        I18n.backend.store_translations("en", "rps" => { "test-rp-2" => { "taxon_name" => taxon_benefits } })
        transaction_data = [
          {
            "simpleId" => simple_id_1, "serviceHomepage" => homepage,
            "loaList" => loa_list, "headlessStartpage" => headless_startpage
          },
          {
            "simpleId" => simple_id_2,
            "loaList" => loa_list,
          },
        ]

        expect(repository).to receive(:get_translations).with(simple_id_1).and_return display_data_1
        expect(repository).to receive(:get_translations).with(simple_id_2).and_return display_data_2
        expect(display_data_1).to receive(:taxon).and_return(taxon_other_services)
        expect(display_data_2).to_not receive(:taxon)

        actual_result = @correlator.correlate(transaction_data)

        expected_result = [
          TransactionTaxonCorrelator::Taxon.new(
            taxon_other_services,
            [
              TransactionTaxonCorrelator::Transaction.new(
                transaction_1_name, taxon_other_services, homepage,
                loa_list, headless_startpage
              ),
              TransactionTaxonCorrelator::Transaction.new(
                transaction_2_name, taxon_other_services, nil,
                loa_list, nil
              ),
            ],
          ),
        ]
        expect(actual_result).to eq expected_result
      end

      it "should sort the taxons alphabetically, with Other services last." do
        I18n.backend.store_translations("en", "rps" => { "test-rp-1" => { "taxon_name" => taxon_other_services } })
        I18n.backend.store_translations("en", "rps" => { "test-rp-2" => { "taxon_name" => taxon_working_jobs_and_pensions } })
        I18n.backend.store_translations("en", "rps" => { "test-rp-a" => { "taxon_name" => taxon_benefits } })

        transaction_data = [
          {
            "simpleId" => simple_id_2, "serviceHomepage" => homepage,
            "loaList" => loa_list, "headlessStartpage" => headless_startpage
          },
          {
            "simpleId" => simple_id_a, "serviceHomepage" => homepage,
            "loaList" => loa_list, "headlessStartpage" => headless_startpage
          },
          {
            "simpleId" => simple_id_1, "serviceHomepage" => homepage,
            "loaList" => loa_list, "headlessStartpage" => headless_startpage
          },
        ]
        expect(display_data_1).to receive(:taxon).and_return(taxon_other_services)
        expect(display_data_2).to receive(:taxon).and_return(taxon_working_jobs_and_pensions)
        expect(display_data_a).to receive(:taxon).and_return(taxon_benefits)
        expect(repository).to receive(:get_translations).with(simple_id_1).and_return display_data_1
        expect(repository).to receive(:get_translations).with(simple_id_2).and_return display_data_2
        expect(repository).to receive(:get_translations).with(simple_id_a).and_return display_data_a

        actual_result = @correlator.correlate(transaction_data)

        expected_result = [
          TransactionTaxonCorrelator::Taxon.new(
            taxon_benefits,
            [
              TransactionTaxonCorrelator::Transaction.new(
                transaction_a_name, taxon_benefits, homepage,
                loa_list, headless_startpage
              ),
            ],
          ),
          TransactionTaxonCorrelator::Taxon.new(
            taxon_working_jobs_and_pensions,
            [
              TransactionTaxonCorrelator::Transaction.new(
                transaction_2_name, taxon_working_jobs_and_pensions, homepage,
                loa_list, headless_startpage
              ),
            ],
          ),
          TransactionTaxonCorrelator::Taxon.new(
            taxon_other_services,
            [
              TransactionTaxonCorrelator::Transaction.new(
                transaction_1_name, taxon_other_services, homepage,
                loa_list, headless_startpage
              ),
            ],
          ),
        ]
        expect(actual_result).to eq expected_result
      end

      it "should sort the transactions within a taxon alphabetically" do
        transaction_data = [
          { "simpleId" => simple_id_2, "serviceHomepage" => homepage, "loaList" => loa_list },
          { "simpleId" => simple_id_b, "serviceHomepage" => homepage, "loaList" => loa_list },
          { "simpleId" => simple_id_a, "serviceHomepage" => homepage, "loaList" => loa_list },
          { "simpleId" => simple_id_1, "serviceHomepage" => homepage, "loaList" => loa_list },
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
          TransactionTaxonCorrelator::Taxon.new(
            taxon_benefits,
            [
              TransactionTaxonCorrelator::Transaction.new(transaction_1_name, taxon_benefits, homepage, loa_list),
              TransactionTaxonCorrelator::Transaction.new(transaction_2_name, taxon_benefits, homepage, loa_list),
              TransactionTaxonCorrelator::Transaction.new(transaction_a_name, taxon_benefits, homepage, loa_list),
              TransactionTaxonCorrelator::Transaction.new(transaction_b_name, taxon_benefits, homepage, loa_list),
            ],
          ),
        ]

        expect(actual_result).to eq expected_results
      end

      it "should not show transactions which are not listed in the enabled list" do
        transaction_data = [
          {
            "simpleId" => simple_id_1, "serviceHomepage" => homepage,
            "loaList" => loa_list, "headlessStartpage" => headless_startpage
          },
          {
            "simpleId" => simple_id_2, "serviceHomepage" => homepage,
            "loaList" => loa_list, "headlessStartpage" => headless_startpage
          },
          {
            "simpleId" => simple_id_a, "serviceHomepage" => homepage,
            "loaList" => loa_list, "headlessStartpage" => headless_startpage
          },
        ]

        expect(repository).to receive(:get_translations).with(simple_id_1).and_return display_data_1
        expect(repository).to_not receive(:get_translations).with(simple_id_2)
        expect(repository).to_not receive(:get_translations).with(simple_id_a)

        expect(display_data_1).to receive(:taxon).and_return(taxon_benefits)
        expect(display_data_2).to_not receive(:taxon)

        test_correlator = TransactionTaxonCorrelator.new(repository, [simple_id_1])
        actual_result = test_correlator.correlate(transaction_data)

        expected_results = [
          TransactionTaxonCorrelator::Taxon.new(
            taxon_benefits,
            [
              TransactionTaxonCorrelator::Transaction.new(
                transaction_1_name, taxon_benefits, homepage,
                loa_list, headless_startpage
              ),
            ],
          ),
        ]
        expect(actual_result).to eq expected_results
      end
    end
  end
end
