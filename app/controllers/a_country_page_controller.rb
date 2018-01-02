require 'partials/eidas_validation_partial_controller'

class ACountryPageController < ApplicationController
  include EidasValidationPartialController
  before_action :ensure_session_eidas_supported

  def index; end
end
