require 'spec_helper'
require 'display/decorated_transaction'

module Display
  RSpec.describe DecoratedTransaction, type: :model do
    context("#taxon") do
      it 'is not the default when homepage is enabled and present' do
        transaction = double("Transaction")
        rp_display_data = instance_double("Display::RpDisplayData")
        taxon = :some_taxon
        decorator = DecoratedTransaction.new(rp_display_data, transaction)
        expect(decorator).to receive(:homepage).and_return(:present)
        expect(rp_display_data).to receive(:taxon).and_return(taxon)
        expect(decorator.taxon).to eql taxon
      end

      it 'is the default when homepage is not enabled' do
        transaction = double("Transaction")
        rp_display_data = instance_double("Display::RpDisplayData")
        taxon = :some_taxon
        decorator = DecoratedTransaction.new(rp_display_data, transaction, false)
        expect(decorator).to_not receive(:homepage)
        expect(rp_display_data).to receive(:default_taxon).and_return(taxon)
        expect(decorator.taxon).to eql taxon
      end

      it 'is the default when homepage is missing' do
        transaction = double("Transaction")
        rp_display_data = instance_double("Display::RpDisplayData")
        taxon = :some_taxon
        decorator = DecoratedTransaction.new(rp_display_data, transaction)
        expect(decorator).to receive(:homepage).and_return(nil)
        expect(rp_display_data).to receive(:default_taxon).and_return(taxon)
        expect(decorator.taxon).to eql taxon
      end
    end

    context("#<=>") do
      it 'compares by name' do
        expect(
          DecoratedTransaction.new(double(name: 'A'), :not_used) <=>
          DecoratedTransaction.new(double(name: 'B'), :not_used)
        ).to eql(-1)

        expect(
          DecoratedTransaction.new(double(name: 'B'), :not_used) <=>
          DecoratedTransaction.new(double(name: 'A'), :not_used)
        ).to eql 1
      end

      it 'is case insensitive' do
        expect(
          DecoratedTransaction.new(double(name: 'A'), :not_used) <=>
          DecoratedTransaction.new(double(name: 'a'), :not_used)
        ).to eql 0
      end
    end
  end
end
