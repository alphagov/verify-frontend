require 'rails_helper'
require 'controller_helper'
require 'api_test_helper'
require 'piwik_test_helper'

describe StartVariantController do
  before(:each) do
    stub_api_idp_list_for_sign_in
    set_session_and_cookies_with_loa('LEVEL_2')
  end

  it 'renders LOA1 start page if service is level 1' do
    set_session_and_cookies_with_loa('LEVEL_1')
    get :index, params: { locale: 'en' }
    expect(subject).to render_template(:start)
  end

  it 'renders LOA2 start page if service is level 2' do
    get :index, params: { locale: 'en' }
    expect(subject).to render_template(:start)
  end

  context 'when form is valid' do
    it 'will redirect to IDP and report the sign-in to piwik when selecting sign-in' do
      stub_piwik_request = stub_piwik_journey_type_request(
        'SIGN_IN',
        'The user started a sign-in journey',
        'LEVEL_2'
      )

      stub_session_select_idp_request('http://idcorp.com')
      stub_piwik_request('action_name' => 'Sign In - IDCorp')

      post :select_idp, params: { locale: 'en', 'entity_id' => 'http://idcorp.com' }
      expect(stub_piwik_request).to have_been_made.once
      expect(session[:selected_idp].simple_id).to eq('stub-idp-one')
      expect(subject).to redirect_to(redirect_to_idp_sign_in_path)
    end

    it 'will redirect to select-documents page and report it to piwik when selecting registration' do
      stub_piwik_request = stub_piwik_journey_type_request(
        'REGISTRATION',
        'The user started a registration journey',
        'LEVEL_2'
      )

      post :register, params: { locale: 'en', 'entity_id' => 'http://idcorp.com' }
      expect(stub_piwik_request).to have_been_made.once
      expect(subject).to redirect_to(select_documents_path)
    end

    it 'will redirect to an error page when the idp is unrecognised' do
      stub_session_select_idp_request('http://blah-de-blah.com')

      post :select_idp, params: { locale: 'en', 'entity_id' => 'http://blah-de-blah.com' }
      expect(response).to have_http_status(:not_found)
    end
  end
end
