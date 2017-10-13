require 'rails_helper'
require 'controller_helper'
require 'api_test_helper'
require 'piwik_test_helper'

describe StartController do
  before(:each) do
    stub_piwik_request_with_rp_and_loa('action_name' => 'The user has reached the start page')
    set_session_and_cookies_with_loa('LEVEL_2')
  end

  it 'renders LOA2 start page if service is level 2' do
    get :index, params: { locale: 'en' }
    expect(a_request_to_piwik).to have_been_made
    expect(subject).to render_template(:start)
  end

  context 'when form is valid' do
    it 'will redirect to sign in page when selection is false' do
      post :request_post, params: { locale: 'en', start_form: { selection: false } }
      expect(subject).to redirect_to('/sign-in')
    end

    it 'will redirect to about page when selection is true' do
      post :request_post, params: { locale: 'en', start_form: { selection: true } }
      expect(subject).to redirect_to('/about')
    end
  end

  context 'when form is invalid' do
    it 'renders itself' do
      post :request_post, params: { locale: 'en' }
      expect(subject).to render_template(:start)
      expect(flash[:errors]).not_to be_empty
    end
  end
end
