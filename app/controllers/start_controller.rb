require "partials/journey_hinting_partial_controller"

class StartController < ApplicationController
  include JourneyHintingPartialController

  layout "slides"
  before_action :set_device_type_evidence

  def index
    restart_journey if identity_provider_selected? && !user_journey_type?(JourneyType::VERIFY)
    @form = StartForm.new({})
    @journey_hint = flash[:journey_hint]
    render :start unless try_render_journey_hint
  end

  def ignore_hint
    remove_hint_and_report
    redirect_to start_path
  end

  def request_post
    @form = StartForm.new(params["start_form"] || {})
    if @form.valid?
      if @form.registration?
        register
      else
        sign_in
      end
    else
      flash.now[:errors] = @form.errors.full_messages.join(", ")
      render :start
    end
  end

  def register
    FEDERATION_REPORTER.report_registration(current_transaction, request)
    session[:journey_type] = JourneyType::Verify::REGISTRATION
    redirect_to about_path
  end

  def sign_in
    FEDERATION_REPORTER.report_sign_in(current_transaction, request)
    session[:journey_type] = JourneyType::Verify::SIGN_IN
    redirect_to sign_in_path
  end
end
