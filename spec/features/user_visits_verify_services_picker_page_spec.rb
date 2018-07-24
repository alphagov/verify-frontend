require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'When the user visits the Verify services picker page' do
  it 'should display the page in English ' do
    stub_transactions_list
    visit '/verify-services'
    expect(page).to have_content t('hub.verify_services.message')
  end

  it 'should display the page in Welsh' do
    stub_transactions_list
    visit '/gwasanaethau-verify'
    expect(page).to have_content t('hub.verify_services.message', locale: :cy)
  end

  it 'should include the appropriate feedback source' do
    stub_transactions_list
    visit '/verify-services'
    expect_feedback_source_to_be(page, 'VERIFY_SERVICES_PAGE', '/verify-services')
  end
end
