class RedirectToIdpWarningController < ApplicationController
  protect_from_forgery except: :continue

  helper_method :user_has_no_docs?, :other_ways_description

  def index
    @idp = decorated_idp
    @recommended = recommended?
    render 'index'
  end

  def continue
    select_idp_response = SESSION_PROXY.select_idp(cookies, selected_identity_provider.entity_id, true)
    set_secure_cookie(CookieNames::VERIFY_JOURNEY_HINT, select_idp_response.encrypted_entity_id)
    report_registration_idp
    redirect_to redirect_to_idp_path
  end

private

  def report_registration_idp
    cvar = Analytics::CustomVariable.build(:register_idp, decorated_idp.display_name)
    recommended = recommended? ? '(recommended)' : '(not recommended)'
    action = "#{decorated_idp.display_name} was chosen for registration #{recommended} #{selected_evidence_values.join(', ')}"
    ANALYTICS_REPORTER.report_custom_variable(request, action, cvar)
  end

  def recommended?
    session.fetch(:selected_idp_was_recommended)
  end

  def decorated_idp
    decorated_idps = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate([selected_identity_provider])
    unless decorated_idps.any?
      # TODO Make pretty
      raise StandardError, 'Could not display any IDPs'
    end
    decorated_idps.first
  end

  def selected_identity_provider
    IdentityProvider.new(session.fetch(:selected_idp))
  end

  def other_ways_description
    transaction = TRANSACTION_INFO_GETTER.get_info(cookies)
    @other_ways_description = transaction.other_ways_description
  end

  def user_has_no_docs?
    (stored_selected_evidence['documents'] || []).empty?
  end
end
