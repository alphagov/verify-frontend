class ResponseProcessingController < ApplicationController
  def index
    @rp_name = current_transaction.rp_name
  end
end
