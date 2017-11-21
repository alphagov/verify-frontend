require 'ab_test/ab_test'

class StartVariantController < ApplicationController
  layout 'slides'

  def index
    @tailored_text = current_transaction.tailored_text
    render :start
  end

  def sign_in
    FEDERATION_REPORTER.report_sign_in(current_transaction, request)
    redirect_to sign_in_path
  end

  def register
    FEDERATION_REPORTER.report_registration(current_transaction, request)
    redirect_to choose_a_certified_company_path
  end
end
