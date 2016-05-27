class RedirectToServiceController < ApplicationController
  def signing_in
    @title = 'hub.redirect_to_service.signing_in.title'
    @response_for_rp = SESSION_PROXY.response_for_rp(cookies)
    @rp_name = current_transaction.rp_name
    @transition_message = t('hub.redirect_to_service.signing_in.transition_heading', rp_name: @rp_name)
    render 'redirect_to_service'
  end

  def start_again
    @title = 'hub.redirect_to_service.start_again.title'
    @response_for_rp = SESSION_PROXY.response_for_rp(cookies)
    @rp_name = current_transaction.rp_name
    @transition_message = t('hub.redirect_to_service.start_again.transition_heading', rp_name: @rp_name)
    render 'redirect_to_service'
  end
end
