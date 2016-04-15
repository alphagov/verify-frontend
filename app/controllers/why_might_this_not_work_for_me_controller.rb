class WhyMightThisNotWorkForMeController < ApplicationController
  def index
    uri = URI(choose_a_certified_company_path)
    uri.query = request.query_string
    @try_to_verify = uri
  end
end
