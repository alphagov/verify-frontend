class RedirectToIdpWarningController < ApplicationController
  protect_from_forgery except: :continue

  helper_method :user_has_no_docs?, :other_ways_description

  def index
    @idp = decorated_idp
    if @idp.viewable?
      @recommended = recommended?
      render 'index'
    else
      something_went_wrong("Couldn't display IDP with entity id: #{@idp.entity_id}")
    end
  end

  def continue
    idp = decorated_idp
    if idp.viewable?
      select_registration(idp)
      redirect_to redirect_to_idp_path
    else
      something_went_wrong("Couldn't display IDP with entity id: #{@idp.entity_id}")
    end
  end

  def continue_ajax
    idp = decorated_idp
    if idp.viewable?
      select_registration(idp)
      authn_request_json = SESSION_PROXY.idp_authn_request(cookies)
      render json: authn_request_json
    else
      render status: :bad_request
    end
  end

private

  def select_registration(idp)
    select_idp_response = SESSION_PROXY.select_idp(cookies, idp.entity_id, true)
    set_secure_cookie(CookieNames::VERIFY_JOURNEY_HINT, select_idp_response.encrypted_entity_id)
    cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = idp.entity_id
    report_registration(idp)
  end

  def report_registration(idp)
    cvar = Analytics::CustomVariable.build(:register_idp, idp.display_name)
    recommended = recommended? ? '(recommended)' : '(not recommended)'
    list_of_evidence = selected_evidence_values.sort.join(', ')
    action = "#{idp.display_name} was chosen for registration #{recommended} with evidence #{list_of_evidence}"
    ANALYTICS_REPORTER.report_custom_variable(request, action, cvar)
  end

  def recommended?
    session.fetch(:selected_idp_was_recommended)
  end

  def decorated_idp
    @decorated_idp ||= IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(selected_identity_provider)
  end

  def selected_identity_provider
    IdentityProvider.new(session.fetch(:selected_idp))
  end

  def other_ways_description
    transaction = TRANSACTION_INFO_GETTER.get_info(session)
    @other_ways_description = transaction.other_ways_description
  end

  def user_has_no_docs?
    (stored_selected_evidence['documents'] || []).empty?
  end
end
