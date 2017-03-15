require 'spec_helper'
require 'rails_helper'

describe FeedbackSourceMapper do
  before(:each) { @feedback_source_mapper = FeedbackSourceMapper.new('http://product_page_url') }

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
