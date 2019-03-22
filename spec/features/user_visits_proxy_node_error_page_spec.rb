require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'When the user visits the Proxy Node error page' do
  it 'should display the page in English ' do
    visit '/proxy-node-error'
    expect(page).to have_content t('errors.proxy_node_error.start_again')
  end

  it 'should display the page in Welsh' do
    visit '/proxy-node-error-cy'
    expect(page).to have_content t('errors.proxy_node_error.start_again', locale: :cy)
  end

  it 'should include the appropriate feedback source' do
    visit '/proxy-node-error'
    expect_feedback_source_to_be(page, 'PROXY_NODE_ERROR_PAGE', '/proxy-node-error')
  end
end
