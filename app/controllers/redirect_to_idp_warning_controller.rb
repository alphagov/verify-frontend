class RedirectToIdpWarningController < ApplicationController
  def index
    idp = IdentityProvider.new(session.fetch(:selected_idp))
    decorated_idps = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate([idp])
    unless decorated_idps.any?
      # TODO Make pretty
      raise StandardError, 'Could not display any IDPs'
    end
    @idp = decorated_idps.first
    render 'index'
  end

  def continue
    redirect_to redirect_to_idp_path
  end
end
