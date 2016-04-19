class WillNotWorkWithoutUkAddressController < ApplicationController
  def index
    transaction_details = TRANSACTION_INFO_GETTER.get_info(cookies)
    @other_ways_description = transaction_details.other_ways_description
    @other_ways_text = transaction_details.other_ways_text
  end
end
