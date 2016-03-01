class SelectIdpController < ApplicationController
  def select_idp
    SESSION_PROXY.select_idp(request.cookies, params.fetch('entityId'))
  end
end
