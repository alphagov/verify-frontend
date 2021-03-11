require "partials/idp_selection_partial_controller"
require "partials/viewable_idp_partial_controller"
require "partials/analytics_cookie_partial_controller"

class SignInController < ApplicationController
  include IdpSelectionPartialController
  include ViewableIdpPartialController
  include AnalyticsCookiePartialController
  include ActionView::Helpers::UrlHelper

  def index
    entity_id = success_entity_id
    all_identity_providers = current_available_identity_providers_for_sign_in + current_disconnected_identity_providers_for_sign_in
    @suggested_idp = entity_id && decorate_idp_by_entity_id(all_identity_providers, entity_id)
    unless @suggested_idp.nil?
      FEDERATION_REPORTER.report_sign_in_journey_hint_shown(current_transaction, request, @suggested_idp.display_name)
      @idp_disconnected_hint_html = get_disconnection_hint_text(@suggested_idp.display_name)
    end

    @identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(current_available_identity_providers_for_sign_in)

    @unavailable_identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(
      current_unavailable_identity_providers_for_sign_in,
    )

    @disconnected_idps = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(current_disconnected_identity_providers_for_sign_in)

    render :index
  end

  def select_idp
    select_viewable_idp_for_sign_in(params.fetch("entity_id")) do |decorated_idp|
      set_journey_hint_followed(decorated_idp.entity_id)
      if idp_disconnecting(decorated_idp) && !session[:warning_shown]
        redirect_to sign_in_warning_path
      else
        session[:warning_shown] = nil
        sign_in(decorated_idp.entity_id, decorated_idp.display_name)
        redirect_to redirect_to_idp_sign_in_path
      end
    end
  end

  def select_idp_ajax
    select_viewable_idp_for_sign_in(params.fetch("entityId")) do |decorated_idp|
      if idp_disconnecting(decorated_idp) && !session[:warning_shown]
        redirect_obj = {
          "location" => sign_in_warning_path.to_s,
          "saml_request" => "",
          "relay_state" => "",
          "registration" => false,
          "hints" => [],
          "language_hint" => "",
        }
        render json: redirect_obj
      else
        session[:warning_shown] = nil
        sign_in(decorated_idp.entity_id, decorated_idp.display_name)
        ajax_idp_redirection_sign_in_request(decorated_idp.entity_id)
      end
    end
  end

  def warn
    logger.warn(request)
    session[:warning_shown] = true
    @idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(selected_identity_provider)
  end

private

  def sign_in(entity_id, idp_name)
    POLICY_PROXY.select_idp(session[:verify_session_id],
                            entity_id,
                            session[:requested_loa],
                            false,
                            persistent_session_id,
                            session[:journey_type],
                            ab_test_with_alternative_name)
    set_attempt_journey_hint(entity_id)
    session[:selected_idp_name] = idp_name
  end

  def get_disconnection_hint_text(idp_name)
    if current_transaction.idp_disconnected_hint_html.nil?
      t("hub.signin.company_no_longer_verifies_text", company: idp_name, link: link_to(t("hub.signin.company_no_longer_verifies_link"), begin_registration_path))
    else
      format(current_transaction.idp_disconnected_hint_html, company: idp_name, begin_registration_path: begin_registration_path)
    end
  end

  def idp_disconnecting(idp)
    disconnection_time = idp.provide_authentication_until
    !disconnection_time.nil? && DateTime.now > disconnection_time - 1.month
  end
end
