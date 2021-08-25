class SelectDocumentsController < ApplicationController
  def index
    render :index
  end

  def prove_your_identity_another_way
    @other_ways_text = current_transaction.other_ways_text
    @service_name = current_transaction.name

    render :prove_your_identity_another_way
  end
end
