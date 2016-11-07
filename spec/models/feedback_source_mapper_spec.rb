require 'spec_helper'
require 'rails_helper'

describe FeedbackSourceMapper do
  it 'should map feedback source to corresponding english path' do
    expect(FeedbackSourceMapper.page_from_source('CONFIRM_YOUR_IDENTITY', :en)).to eql(confirm_your_identity_path)
    expect(FeedbackSourceMapper.page_from_source('ABOUT_IDENTITY_ACCOUNTS_PAGE', :en)).to eql(about_identity_accounts_path)
  end

  it 'should map company about feedback source to choose company page' do
    expect(FeedbackSourceMapper.page_from_source('CHOOSE_A_CERTIFIED_COMPANY_ABOUT_SOME_IDP_PAGE', :en)).to eql(choose_a_certified_company_path)
  end

  it 'should map feedback source to corresponding welsh path' do
    expect(FeedbackSourceMapper.page_from_source('CONFIRM_YOUR_IDENTITY', :cy)).to eql('/cadarnhau-eich-hunaniaeth')
  end

  it 'should map error feedback source to start page' do
    expect(FeedbackSourceMapper.page_from_source('ERROR_PAGE', :en)).to eql(start_path)
  end

  it 'should map unknown feedback source to start page' do
    expect(FeedbackSourceMapper.page_from_source('BLAH', :en)).to eql(start_path)
  end

  it 'should map missing feedback source to start page' do
    expect(FeedbackSourceMapper.page_from_source(nil, :en)).to eql(start_path)
  end
end
