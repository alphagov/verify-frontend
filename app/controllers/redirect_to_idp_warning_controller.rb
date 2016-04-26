class RedirectToIdpWarningController < ApplicationController
  helper_method :user_has_no_docs?, :other_ways_description

  def index
    idp = selected_identity_provider
    decorated_idps = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate([idp])
    unless decorated_idps.any?
      # TODO Make pretty
      raise StandardError, 'Could not display any IDPs'
    end
    @idp = decorated_idps.first
    @recommended = session.fetch(:selected_idp_was_recommended)
    render 'index'
  end

  def continue
    select_idp_response = SESSION_PROXY.select_idp(cookies, selected_identity_provider.entity_id, true)
    set_secure_cookie(CookieNames::VERIFY_JOURNEY_HINT, select_idp_response.encrypted_entity_id)
    redirect_to redirect_to_idp_path
  end

private

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
