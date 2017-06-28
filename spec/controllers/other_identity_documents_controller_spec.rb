require 'rails_helper'
require 'controller_helper'
require 'api_test_helper'
require 'piwik_test_helper'

describe OtherIdentityDocumentsController do
  before(:each) do
    set_session_and_cookies_with_loa('LEVEL_1')
    stub_api_idp_list
    stub_piwik_request('action_name' => 'Other Documents Next')
  end

  it 'should go to select phone path and set selected answers when user has other identity documents' do
    post :select_other_documents, params: {
      locale: 'en',
      other_identity_documents_form: { non_uk_id_document: 'true' }
    }

    expect(subject).to redirect_to(select_phone_path)
    expect(session[:selected_answers]).to eql('documents' => { non_uk_id_document: true })
  end

  it 'should not advance if form is invalid' do
    post :select_other_documents, params: {
      locale: 'en',
      other_identity_documents_form: { non_uk_id_document: 'blah' }
    }

    expect(subject).to render_template('index')
  end

  it 'will only contain has non-uk id document and will ignore any stale form values for passport and licence' do
    session[:selected_answers] = { 'documents' => { driving_licence: true, passport: true } }

    post :select_other_documents, params: {
      locale: 'en',
      other_identity_documents_form: { non_uk_id_document: 'true' }
    }

    expect(session[:selected_answers]).to eql('documents' => { non_uk_id_document: true })
  end
end
