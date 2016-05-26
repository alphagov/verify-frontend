class RedirectToServiceController < ApplicationController
  def signing_in
    @response_for_rp = SESSION_PROXY.response_for_rp(cookies)
  end
end
