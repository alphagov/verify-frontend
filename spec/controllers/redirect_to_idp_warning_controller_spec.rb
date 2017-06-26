require 'rails_helper'
require 'controller_helper'
require 'api_test_helper'

describe RedirectToIdpWarningController do
  subject { get :index, params: { locale: 'en' } }

  before :each do
    set_session_and_cookies_with_loa('LEVEL_2')
    session[:selected_idp_was_recommended] = [true, false].sample
  end

  it 'renders idp warning page when idp has been selected' do
    session[:selected_idp] = { 'simple_id' => 'stub-idp-two',
                               'entity_id' => 'http://idcorp.com',
                               'levels_of_assurance' => %w(LEVEL_1 LEVEL_2) }

    expect(subject).to render_template(:index)
  end

  it 'shows error page when no idp selected' do
    session[:selected_idp] = {}

    expect(subject).to render_template('errors/something_went_wrong')
  end
end
