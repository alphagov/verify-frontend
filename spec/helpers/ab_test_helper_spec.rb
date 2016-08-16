require 'rails_helper'

RSpec.describe AbTestHelper, type: :helper do
  describe '#ab_test' do
    let(:cookies) {
      helper.request.cookies
    }
    it 'should return alternative name when the given cookie value is valid' do
      cookies[CookieNames::AB_TEST] = { 'about_companies' => 'about_companies_with_logo' }.to_json
      alternative_name = helper.ab_test('about_companies')
      expect(alternative_name).to eq('about_companies_with_logo')
    end

    it 'should return no_logos_privacy when the given cookie value no_logos_privacy' do
      cookies[CookieNames::AB_TEST] = { 'about_companies' => 'about_companies_no_logo_privacy' }.to_json
      alternative_name = helper.ab_test('about_companies')
      expect(alternative_name).to eq('about_companies_no_logo_privacy')
    end

    it 'should return default alternative name when the given cookie value is invalid' do
      cookies[CookieNames::AB_TEST] = 'DROP TABLES;'
      alternative_name = helper.ab_test('about_companies')
      expect(alternative_name).to eq('about_companies_with_logo')
    end

    it 'should return default alternative name when ab_test cookie is absent' do
      alternative_name = helper.ab_test('about_companies')
      expect(alternative_name).to eq('about_companies_with_logo')
    end

    it 'should return default alternative name when ab_test cookie is nil' do
      cookies['ab_test'] = nil
      alternative_name = helper.ab_test('about_companies')
      expect(alternative_name).to eq('about_companies_with_logo')
    end

    it 'should return nil if there is no experiment' do
      alternative_name = helper.ab_test('another_experiment')
      expect(alternative_name).to eq(nil)
    end

    it 'should return default if there is no experiment' do
      alternative_name = helper.ab_test('another_experiment', 'default_value')
      expect(alternative_name).to eq('default_value')
    end
  end
end
