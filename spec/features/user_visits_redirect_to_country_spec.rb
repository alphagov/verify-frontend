require 'feature_helper'
require 'api_test_helper'
require 'i18n'

RSpec.describe 'When the user visits the redirect to country page' do
  before(:each) do
    set_session_and_session_cookies!
    stub_transactions_list
  end

  def no_eidas_session
    'no-eidas-session'
  end

  def given_a_session_not_supporting_eidas
    page.set_rack_session(
      verify_session_id: no_eidas_session,
      transaction_supports_eidas: false
    )
  end

  it 'should show something went wrong when visiting redirect to country page directly with session not supporting eidas' do
    given_a_session_not_supporting_eidas

    visit '/redirect-to-country'
    expect(page).to have_content 'Sorry, something went wrong'
  end
end
