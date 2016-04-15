class WhyMightThisNotWorkForMeController < ApplicationController
  def index
    uri = URI(choose_a_certified_company_path)
    uri.query = request.query_string
    @try_to_verify = uri
    transaction_details = TRANSACTION_INFO_GETTER.get_info(cookies)
    @other_ways_description = transaction_details.other_ways_description
    @other_ways_text = transaction_details.other_ways_text
  end
end
