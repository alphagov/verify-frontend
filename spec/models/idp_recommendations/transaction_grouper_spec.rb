require 'idp_recommendations/transaction_grouper'

describe 'Transaction Grouper' do
  before(:each) do
    @transaction_grouper = TransactionGroups::TransactionGrouper.new('protected_transactions' => %w(protected-rp-1 protected-rp-2))
  end

  it 'should return protected if the the transaction is listed as protected' do
    result = @transaction_grouper.get_transaction_group('protected-rp-1')
    expect(result).to eql TransactionGroups::PROTECTED
  end

  it 'should return non-protected if the transaction is not listed as protected' do
    result = @transaction_grouper.get_transaction_group('non-protected-rp-1')
    expect(result).to eql TransactionGroups::NON_PROTECTED
  end
end
