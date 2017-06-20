require 'rails_helper'
require 'controller_helper'
require 'spec_helper'
require 'api_test_helper'

describe FailedRegistrationController do
  before(:each) do
    set_session_and_cookies_with_loa('LEVEL_1')
    session[:selected_idp] = { 'entity_id' => 'http://idcorp.com', 'simple_id' => 'stub-idp-one', 'levels_of_assurance' => %w(LEVEL_1 LEVEL_2) }
    session[:selected_idp_was_recommended] = true
  end

  subject { get :index, params: { locale: 'en' } }

  it 'renders the correct view when continue to failed registration RPs is false' do
    session[:transaction_simple_id] = 'test-rp'
    expect(subject).to render_template(:index)
  end

  it 'renders the correct view when continue to failed registration RPs is true' do
    session[:transaction_simple_id] = 'test-rp-with-continue-on-fail'
    expect(subject).to render_template(:index_continue_on_failed_registration)
  end
end
