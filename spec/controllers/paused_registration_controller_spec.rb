require 'rails_helper'
require 'controller_helper'
require 'spec_helper'
require 'api_test_helper'

describe PausedRegistrationController do
  before(:each) do
    session[:selected_idp] = { 'entity_id' => 'http://idcorp.com', 'simple_id' => 'stub-idp-one', 'levels_of_assurance' => %w(LEVEL_1 LEVEL_2) }
    set_session_and_cookies_with_loa('LEVEL_2', 'test-rp')
  end

  subject { get :index, params: { locale: 'en' } }

  it 'renders paused registration page' do
    expect(subject).to render_template(:with_user_session)
  end

  it 'should render paused registration without session page when there is no idp selected' do
    session.delete(:selected_idp)

    expect(subject).to render_template(:without_user_session)
  end
end
