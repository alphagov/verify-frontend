require 'rails_helper'
require 'controller_helper'
require 'api_test_helper'
require 'piwik_test_helper'

describe SignInController do
  before(:each) do
    stub_api_idp_list([{ 'simpleId' => 'stub-idp-one',
                         'entityId' => 'http://idcorp.com',
                         'levelsOfAssurance' => %w(LEVEL_1) }])
    set_session_and_cookies_with_loa('LEVEL_1')
  end

  context '#index' do
    it 'will report to piwik when the user has selected the No option on the introduction page' do
      stub_piwik_request('action_name' => 'The No option was selected on the introduction page')
      stub_piwik_report_loa_requested('LEVEL_1')

      get :index, params: { locale: 'en' }
      expect(subject).to render_template(:index)
    end
  end

  context '#select_idp' do
    it 'will redirect to the path for the selected IDP' do
      stub_session_select_idp_request('http://idcorp.com')
      stub_piwik_request('action_name' => 'Sign In - IDCorp')

      post :select_idp, params: { locale: 'en', 'entity_id' => 'http://idcorp.com' }
      expect(session[:selected_idp].simple_id).to eq('stub-idp-one')
      expect(subject).to redirect_to(redirect_to_idp_path)
    end

    it 'will redirect to an error page when the idp is unrecognised' do
      stub_session_select_idp_request('http://blah-de-blah.com')

      post :select_idp, params: { locale: 'en', 'entity_id' => 'http://blah-de-blah.com' }
      expect(response).to have_http_status(:not_found)
    end
  end
end
