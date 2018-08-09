require 'partials/idp_selection_partial_controller'
require 'partials/viewable_idp_partial_controller'

class StartController < ApplicationController
  include IdpSelectionPartialController
  include ViewableIdpPartialController
  layout 'slides'
  before_action :set_device_type_evidence

  def index
    session.delete(:selected_country)
    entity_id = entity_id_of_journey_hint_for('SUCCESS')
    @suggested_idp = entity_id.nil? ? [] : retrieve_decorated_singleton_idp_array_by_entity_id(current_identity_providers_for_sign_in, entity_id)
    if @suggested_idp.empty? || !defined?(@suggested_idp)
      @form = StartForm.new({})
      render :start
    else
      render :start_with_hint
    end
  end

  def request_post
    @form = StartForm.new(params['start_form'] || {})
    if @form.valid?
      if @form.registration?
        register
      else
        sign_in
      end
    else
      flash.now[:errors] = @form.errors.full_messages.join(', ')
      render :start
    end
  end

  def register
    FEDERATION_REPORTER.report_registration(current_transaction, request)
    session[:journey_type] = 'registration'
    redirect_to about_path
  end

  def sign_in
    FEDERATION_REPORTER.report_sign_in(current_transaction, request)
    session[:journey_type] = 'sign-in'
    redirect_to sign_in_path
  end
end
