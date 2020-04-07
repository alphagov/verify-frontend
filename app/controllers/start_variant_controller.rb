require 'partials/journey_hinting_partial_controller'
require 'partials/viewable_idp_partial_controller'

class StartVariantController < ApplicationController
  include JourneyHintingPartialController
  include ViewableIdpPartialController

  layout 'slides'
  before_action :set_device_type_evidence

  def index
    restart_journey if identity_provider_selected? && !user_journey_type?(JourneyType::VERIFY)
    journey_hint_entity_id = success_entity_id
    @form = StartForm.new({})
    @journey_hint = flash[:journey_hint]
    if journey_hint_entity_id.nil?
      render 'start/start'
    else
      @identity_provider = retrieve_decorated_singleton_idp_array_by_entity_id(current_available_identity_providers_for_sign_in, journey_hint_entity_id).first
      if @identity_provider.nil?
        return render 'start/start'
      end

      render 'shared/sign_in_hint', layout: 'main_layout'
    end
  end

  def ignore_hint
    journey_hint_entity_id = success_entity_id
    remove_success_journey_hint
    idp = retrieve_decorated_singleton_idp_array_by_entity_id(current_available_identity_providers_for_sign_in, journey_hint_entity_id).first unless journey_hint_entity_id.nil?
    unless idp.nil?
      FEDERATION_REPORTER.report_sign_in_journey_ignored(current_transaction, request, idp.display_name, session[:transaction_simple_id])
    end
    redirect_to start_path
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
      render 'start/start'
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
