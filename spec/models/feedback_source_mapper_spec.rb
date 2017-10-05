require 'spec_helper'
require 'rails_helper'

describe FeedbackSourceMapper do
  before(:each) { @feedback_source_mapper = FeedbackSourceMapper.new('http://product_page_url') }

  it 'should map to anywhere if feedback source is COOKIE_NOT_FOUND_PAGE' do
    expect(@feedback_source_mapper.page_from_source('COOKIE_NOT_FOUND_PAGE', :en)).to be_nil
  end

  it 'COOKIE_NOT_FOUND_PAGE feedback source should be valid' do
    expect(@feedback_source_mapper.is_feedback_source_valid('COOKIE_NOT_FOUND_PAGE')).to be true
  end

  it 'EXPIRED_ERROR_PAGE feedback source should be valid' do
    expect(@feedback_source_mapper.is_feedback_source_valid('EXPIRED_ERROR_PAGE')).to be true
  end

  it 'feedback source should be valid if it is from any about company page' do
    expect(@feedback_source_mapper.is_feedback_source_valid('CHOOSE_A_CERTIFIED_COMPANY_ABOUT_SOME_IDP_PAGE')).to be true
  end

  it 'should map to anywhere if feedback source is EXPIRED_ERROR_PAGE' do
    expect(@feedback_source_mapper.page_from_source('EXPIRED_ERROR_PAGE', :en)).to be_nil
  end

  it 'should map feedback source to product page' do
    expect(@feedback_source_mapper.page_from_source('PRODUCT_PAGE', :en)).to eql('http://product_page_url')
  end

  it 'should map feedback source to corresponding english path' do
    expect(@feedback_source_mapper.page_from_source('CONFIRM_YOUR_IDENTITY', :en)).to eql(confirm_your_identity_path)
    expect(@feedback_source_mapper.page_from_source('ABOUT_IDENTITY_ACCOUNTS_PAGE', :en)).to eql(about_identity_accounts_path)
  end

  it 'should map company about feedback source to choose company page' do
    expect(@feedback_source_mapper.page_from_source('CHOOSE_A_CERTIFIED_COMPANY_ABOUT_SOME_IDP_PAGE', :en)).to eql(choose_a_certified_company_path)
  end

  it 'should map feedback source to corresponding welsh path' do
    expect(@feedback_source_mapper.page_from_source('CONFIRM_YOUR_IDENTITY', :cy)).to eql('/cadarnhau-eich-hunaniaeth')
  end

  it 'should map error feedback source to start page' do
    expect(@feedback_source_mapper.page_from_source('ERROR_PAGE', :en)).to eql(start_path)
  end

  it 'should map unknown feedback source to start page' do
    expect(@feedback_source_mapper.page_from_source('BLAH', :en)).to eql(start_path)
  end

  it 'should map missing feedback source to start page' do
    expect(@feedback_source_mapper.page_from_source(nil, :en)).to eql(start_path)
  end
end
