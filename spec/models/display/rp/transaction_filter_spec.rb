require 'spec_helper'
require 'models/display/rp/transaction_filter'

module Display
  module Rp
    describe TransactionFilter do
      RPTransactions = Struct.new(:name_homepage, :name_only)
      Transaction = Struct.new(:name, :homepage, :loa_list)

      let(:rp_loa1) { Transaction.new('rp-loa1', 'http://example-loa1.com', %w(LEVEL_1 LEVEL_2)) }
      let(:rp_loa2) { Transaction.new('rp-loa2', 'http://example-loa2.com', %w(LEVEL_2)) }
      let(:rp_name_only_loa2) { Transaction.new('rp-name-only-loa2', nil, %w(LEVEL_2)) }
      let(:transactions) { RPTransactions.new([rp_loa1, rp_loa2], [rp_name_only_loa2]) }
      let(:empty_transactions) { RPTransactions.new([], []) }

      it 'should provide a list of LOA1 transactions from a list containing LOA1 and LOA2 transactions' do
        expect(subject.filter_by_loa(transactions, 'LEVEL_1')).to eql([rp_loa1])
      end

      it 'should provide a list of LOA2 transactions from a list containing LOA1 and LOA2 transactions' do
        expect(subject.filter_by_loa(transactions, 'LEVEL_2')).to eql([rp_loa2, rp_name_only_loa2])
      end

      it 'should return an empty list if it is given an empty list of transactions' do
        expect(subject.filter_by_loa(empty_transactions, 'LEVEL_1')).to eql([])
      end
    end
  end
end
