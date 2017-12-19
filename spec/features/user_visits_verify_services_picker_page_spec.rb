require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'When the user visits the Verify services picker page' do
  it 'should display the page in English ' do
    stub_transactions_list
    visit '/verify-services'
    expect(page).to have_content('GOV.UK Verify is new, and government services are joining all the time. The current services using Verify are:')
  end

  it 'should display the page in Welsh' do
    stub_transactions_list
    visit '/verify-services-cy'
    expect(page).to have_content('GOV.UK Verify is new, and government services are joining all the time. The current services using Verify are:')
  end

  it 'should include the appropriate feedback source' do
    stub_transactions_list
    visit '/verify-services'
    expect_feedback_source_to_be(page, 'VERIFY_SERVICES_PAGE', '/verify-services')
  end
end
