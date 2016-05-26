class RedirectToServiceController < ApplicationController
  def signing_in
    @title = t('hub.redirect_to_service.signing_in.title')
    @response_for_rp = SESSION_PROXY.response_for_rp(cookies)
    render 'redirect_to_service'
  end

  def start_again
    @title = t('hub.redirect_to_service.start_again.title')
    @response_for_rp = SESSION_PROXY.response_for_rp(cookies)
    render 'redirect_to_service'
  end
end
