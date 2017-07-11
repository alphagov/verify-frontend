class NoIdpsAvailableController < ApplicationController
  def index
    @other_ways_description = current_transaction.other_ways_description
    @other_ways_text = current_transaction.other_ways_text
    render :no_idps_available
  end
end
