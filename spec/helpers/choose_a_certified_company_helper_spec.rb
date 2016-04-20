require 'spec_helper'
require 'rails_helper'

RSpec.describe ChooseACertifiedCompanyHelper, type: :helper do
  describe '#recommended_company_message' do
    it 'should show zero companies message when count is zero' do
      expect(helper.recommended_company_message(0)).to eql 'Based on your answers, no&nbsp;companies can verify you now:'
    end

    it 'should show one company message when count is one' do
      expect(helper.recommended_company_message(1)).to eql 'Based on your answers, 1&nbsp;company can verify you now:'
    end

    it 'should show multiple company message when count is greater than one' do
      expect(helper.recommended_company_message(4)).to eql 'Based on your answers, 4&nbsp;companies can verify you now:'
    end
  end
end
