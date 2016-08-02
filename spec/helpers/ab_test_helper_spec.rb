require 'rails_helper'

RSpec.describe AbTestHelper, type: :helper do
  describe '#ab_test' do
    it 'should return alternative name when the given cookie value is valid' do
      cookies['ab_test'] = 'logos_yes'
      alternative_name = helper.ab_test
      expect(alternative_name).to eq('logos_yes')
    end

    it 'should return default alternative name when the given cookie value is invalid' do
      cookies['ab_test'] = 'DROP TABLES;'
      alternative_name = helper.ab_test
      expect(alternative_name).to eq('logos_yes')
    end

    it 'should return default alternative name when ab_test cookie is absent' do
      alternative_name = helper.ab_test
      expect(alternative_name).to eq('logos_yes')
    end

    it 'should return default alternative name when ab_test cookie is nil' do
      cookies['ab_test'] = nil
      alternative_name = helper.ab_test
      expect(alternative_name).to eq('logos_yes')
    end
  end
end
