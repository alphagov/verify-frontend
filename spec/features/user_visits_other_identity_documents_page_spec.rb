require 'feature_helper'
require 'api_test_helper'

RSpec.feature 'When users visits other documents page' do
  it 'should show a feedback link' do
    set_session_and_session_cookies!
    visit '/other-identity-documents'

    expect_feedback_source_to_be(page, 'OTHER_IDENTITY_DOCUMENTS_PAGE', '/other-identity-documents')
  end
end
