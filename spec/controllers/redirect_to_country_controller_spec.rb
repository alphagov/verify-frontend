require 'rails_helper'
require 'controller_helper'
require 'api_test_helper'

describe RedirectToCountryController do
  let(:originating_ip) { '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>' }
  before(:each) do
    set_session_and_cookies_with_loa('LEVEL_2')
    session[:transaction_supports_eidas] = true
    stub_countries_list
    stub_session_country_authn_request(originating_ip, redirect_to_country_path, false)
  end

  it 'deletes selected_idp from session' do
    stub_select_country_request('YY')
    session[:selected_idp] = 'stub-idp'

    post :choose_a_country_submit, params: { locale: 'en', country: 'YY' }

    expect(session[:selected_country]).to_not be_nil
    expect(session[:selected_country].simple_id).to eq('YY')
    expect(session[:selected_idp]).to be_nil
  end
end
