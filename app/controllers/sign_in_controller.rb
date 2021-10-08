class SignInController < IdpSelectionController
  include ActionView::Helpers::UrlHelper

  protect_from_forgery with: :exception, except: :warn_idp_disconnecting

  helper_method :get_disconnection_hint_text

  def index
    all_idps = identity_providers_for_sign_in

    if success_entity_id
      @suggested_idp = decorate_idp_by_entity_id(all_idps[:available] + all_idps[:disconnected], success_entity_id)
      FEDERATION_REPORTER.report_sign_in_journey_hint_shown(current_transaction, request, @suggested_idp.display_name)
    end

    @available_identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(all_idps[:available])
    @unavailable_identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(all_idps[:unavailable])
    @disconnected_idps = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(all_idps[:disconnected])

    render :index
  end

  def select_idp
    unless select_idp_for_sign_in(params.fetch("entity_id", nil)) { redirect_to_idp }
      redirect_to sign_in_warning_path
    end
  end

  def select_idp_ajax
    unless select_idp_for_sign_in(params.fetch("entityId", nil)) { ajax_idp_redirection_request }
      render json: { location: sign_in_warning_path }
    end
  end

  def confirm_idp
    redirect_to_idp
  end

  def warn_idp_disconnecting
    @idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(selected_identity_provider)
  end

private

  def select_idp_for_sign_in(entity_id)
    register_idp_selection_in_session(entity_id) do |decorated_idp|
      unless idp_disconnecting_for_sign_in(decorated_idp)
        if has_journey_hint?
          FEDERATION_REPORTER.report_sign_in_idp_selection_after_journey_hint(current_transaction, request, session[:selected_idp_name], session[:user_followed_journey_hint])
        else
          FEDERATION_REPORTER.report_sign_in_idp_selection(current_transaction: current_transaction, request: request, idp_name: session[:selected_idp_name])
        end

        yield decorated_idp
        return true
      end
    end
  end

  def idp_disconnecting_for_sign_in(idp)
    disconnection_time = idp.provide_authentication_until
    disconnection_time && DateTime.now > disconnection_time - 1.month
  end

  def get_disconnection_hint_text(idp_name)
    if current_transaction.idp_disconnected_hint_html.nil?
      t("hub.signin.company_no_longer_verifies_text", company: idp_name, link: link_to(t("hub.signin.company_no_longer_verifies_link"), begin_registration_path))
    else
      format(current_transaction.idp_disconnected_hint_html, company: idp_name, begin_registration_path: begin_registration_path)
    end
  end
end
