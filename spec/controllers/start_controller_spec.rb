require 'rails_helper'
require 'controller_helper'
require 'api_test_helper'
require 'piwik_test_helper'

describe StartController do
  before(:each) do
    set_session_and_cookies_with_loa('LEVEL_1')
  end

  context '#index' do
    it 'will report to piwik when the user lands on the page' do
      stub_piwik_request_with_rp('action_name' => 'The user has reached the start page')
      get :index, params: { locale: 'en' }
      expect(a_request_to_piwik).to have_been_made
      expect(subject).to render_template(:start)
    end
  end
end
