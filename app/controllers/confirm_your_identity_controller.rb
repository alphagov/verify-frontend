class ConfirmYourIdentityController < ApplicationController
  def index
    transaction_details = TRANSACTION_INFO_GETTER.get_info(cookies)
    @transaction_name = transaction_details.name
  end
end
