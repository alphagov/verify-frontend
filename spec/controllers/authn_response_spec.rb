require 'rails_helper'
require 'controller_helper'
require 'authn_response_examples'

describe AuthnResponseController do
  context 'registration' do
    include_examples 'idp_authn_response', 'registration', 'SUCCESS', 'Success - REGISTER_WITH_IDP at LOA LEVEL_1', :confirmation_path
    include_examples 'idp_authn_response', 'registration', 'CANCEL', 'Cancel - REGISTER_WITH_IDP', :failed_registration_path
    include_examples 'idp_authn_response', 'registration', 'FAILED_UPLIFT', 'Failed Uplift - REGISTER_WITH_IDP', :failed_uplift_path
    include_examples 'idp_authn_response', 'registration', 'OTHER', 'Failure - REGISTER_WITH_IDP', :failed_registration_path
  end

  context 'sign_in' do
    include_examples 'idp_authn_response', 'sign_in', 'SUCCESS', 'Success - SIGN_IN_WITH_IDP at LOA LEVEL_1', :response_processing_path
    include_examples 'idp_authn_response', 'sign_in', 'CANCEL', 'Cancel - SIGN_IN_WITH_IDP', :start_path
    include_examples 'idp_authn_response', 'sign_in', 'FAILED_UPLIFT', 'Failed Uplift - SIGN_IN_WITH_IDP', :failed_uplift_path
    include_examples 'idp_authn_response', 'sign_in', 'OTHER', 'Failure - SIGN_IN_WITH_IDP', :failed_sign_in_path
  end
end
