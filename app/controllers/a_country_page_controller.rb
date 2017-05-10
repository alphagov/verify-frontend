class ACountryPageController < ApplicationController
  before_action :validate_session
  before_action :ensure_session_eidas_supported

  def index
  end
end
