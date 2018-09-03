require 'spec_helper'
require 'active_model'
require 'transaction_list'
require 'display/rp_display_data'
require 'display/rp_display_repository'

RSpec.describe TransactionList, type: :model do
  context "#sort" do
    it "will sort using transactions and return a TransactionList" do
      unsorted_list = TransactionList.new([5, 4, 3, 2, 1])
      sorted_list = TransactionList.new([1, 2, 3, 4, 5])
      expect(unsorted_list.sort).to eq sorted_list
    end
  end

  context "#group_by_taxon" do
    it 'will group into `Taxon`s' do
      transactions = [
        transaction_one = double(taxon: :taxon_one),
        transaction_two = double(taxon: :taxon_two),
        transaction_three = double(taxon: :taxon_one),
        transaction_four = double(taxon: :taxon_two),
      ]
      expect(TransactionList.new(transactions).group_by_taxon).to eql [
        Taxon.new(:taxon_one, [transaction_one, transaction_three]),
        Taxon.new(:taxon_two, [transaction_two, transaction_four]),
      ]
    end
  end

  context "#select_enabled" do
    it 'will select the rps that can be listed' do
      transactions = [
        transaction_one = double(simple_id: :simple_id_one),
        transaction_two = double(simple_id: :simple_id_two),
        double(simple_id: :simple_id_three),
        double(simple_id: :simple_id_four),
      ]
      rps_with_homepage = [:simple_id_one]
      rps_without_homepage = [:simple_id_two]
      expect(TransactionList).to receive(:rps_with_homepage).and_return(rps_with_homepage)
      expect(TransactionList).to receive(:rps_without_homepage).and_return(rps_without_homepage)
      expect(TransactionList.new(transactions).select_enabled.to_a).to eql [transaction_one, transaction_two]
    end
  end

  context "#select_enabled" do
    it 'will select the rps that can share their homepage' do
      transactions = [
        transaction_one = double(simple_id: :simple_id_one),
        double(simple_id: :simple_id_two),
      ]
      rps_with_homepage = [:simple_id_one]
      expect(TransactionList).to receive(:rps_with_homepage).and_return(rps_with_homepage)
      expect(TransactionList.new(transactions).select_with_homepage.to_a).to eql [transaction_one]
    end
  end
  context "#select_enabled" do
    it 'will select the rps that can be shared but without their homepage' do
      transactions = [
        transaction_one = double(simple_id: :simple_id_one),
        double(simple_id: :simple_id_two),
      ]
      rps_without_homepage = [:simple_id_one]
      expect(TransactionList).to receive(:rps_without_homepage).and_return(rps_without_homepage)
      expect(TransactionList.new(transactions).select_without_homepage.to_a).to eql [transaction_one]
    end
  end

  context "#with_display_data" do
    it 'will decorate the transactions in the list' do
      transactions = [
        transaction_one = double(simple_id: :simple_id_one),
        transaction_two = double(simple_id: :simple_id_two),
        transaction_three = double(simple_id: :simple_id_three),
        transaction_four = double(simple_id: :simple_id_four),
      ]

      display_data_one = instance_double("Display::RpDisplayData")
      display_data_two = instance_double("Display::RpDisplayData")
      display_data_three = instance_double("Display::RpDisplayData")
      display_data_four = instance_double("Display::RpDisplayData")

      repository = instance_double("Display::RpDisplayRepository")

      expect(TransactionList).to receive(:rp_display_repository).and_return(repository)

      expect(repository).to receive(:get_translations).with(:simple_id_one).and_return(display_data_one)
      expect(repository).to receive(:get_translations).with(:simple_id_two).and_return(display_data_two)
      expect(repository).to receive(:get_translations).with(:simple_id_three).and_return(display_data_three)
      expect(repository).to receive(:get_translations).with(:simple_id_four).and_return(display_data_four)

      expect(TransactionList.new(transactions).with_display_data.to_a).to eq [
        Display::DecoratedTransaction.new(display_data_one, transaction_one),
        Display::DecoratedTransaction.new(display_data_two, transaction_two),
        Display::DecoratedTransaction.new(display_data_three, transaction_three),
        Display::DecoratedTransaction.new(display_data_four, transaction_four),
      ]
    end

    it 'will skip decorating transactions without valid display data' do
      transactions = [
        transaction_one = double(simple_id: :simple_id_one),
        double(simple_id: :simple_id_two),
      ]

      display_data_one = instance_double("Display::RpDisplayData")

      repository = instance_double("Display::RpDisplayRepository")

      expect(TransactionList).to receive(:rp_display_repository).and_return(repository)

      expect(repository).to receive(:get_translations).with(:simple_id_one).and_return(display_data_one)

      exception = I18n::MissingTranslationData.new(nil, nil)
      expect(repository).to receive(:get_translations).with(:simple_id_two).and_raise exception

      logger = double(:logger)
      expect(TransactionList).to receive(:logger).and_return(logger)
      expect(logger).to receive(:error).with(exception)

      expect(TransactionList.new(transactions).with_display_data.to_a).to eq [
        Display::DecoratedTransaction.new(display_data_one, transaction_one),
      ]
    end
  end

  context "::from" do
    it 'will validate the transactions before creating a list' do
      transactions = [
        transaction_one = double(simple_id: :simple_id_one),
        transaction_two = double(simple_id: :simple_id_two),
      ]

      expect(transaction_one).to receive(:valid?).and_return true
      expect(transaction_two).to receive(:valid?).and_return true
      expect(TransactionList.from(transactions)).to eq TransactionList.new(transactions)
    end

    it 'will return an empty list if there are any validation errors' do
      transactions = [
        transaction_one = double(simple_id: simple_id_one = :simple_id_one),
        transaction_two = double(simple_id: :simple_id_two),
      ]

      transaction_one_error_messages = "Transaction one error messages"

      logger = double(:logger)
      expect(TransactionList).to receive(:logger).and_return(logger)
      expect(logger).to receive(:error).with("#{simple_id_one}: #{transaction_one_error_messages}")

      expect(transaction_one).to receive(:valid?).and_return false
      expect(transaction_two).to receive(:valid?).and_return true
      expect(transaction_one).to receive(:error_messages).and_return transaction_one_error_messages
      expect(TransactionList.from(transactions).to_a).to be_empty
    end

    it 'will report all validation errors' do
      transactions = [
        transaction_one = double(simple_id: simple_id_one = :simple_id_one),
        transaction_two = double(simple_id: simple_id_two = :simple_id_two),
      ]

      transaction_one_error_messages = "Transaction 1 error messages"
      transaction_two_error_messages = "Transaction 2 error messages"

      logger = double(:logger)
      expect(TransactionList).to receive(:logger).and_return(logger).twice
      expect(logger).to receive(:error).with("#{simple_id_one}: #{transaction_one_error_messages}")
      expect(logger).to receive(:error).with("#{simple_id_two}: #{transaction_two_error_messages}")

      expect(transaction_one).to receive(:valid?).and_return false
      expect(transaction_two).to receive(:valid?).and_return false
      expect(transaction_one).to receive(:error_messages).and_return transaction_one_error_messages
      expect(transaction_two).to receive(:error_messages).and_return transaction_two_error_messages
      expect(TransactionList.from(transactions).to_a).to be_empty
    end
  end
end
