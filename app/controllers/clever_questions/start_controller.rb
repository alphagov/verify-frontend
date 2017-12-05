require 'ab_test/ab_test'

class CleverQuestions::StartController < ApplicationController
  layout 'slides'

  def index
    FEDERATION_REPORTER.report_start_page(current_transaction, request)
    render :start
  end

  def sign_in
    FEDERATION_REPORTER.report_sign_in(current_transaction, request)
    redirect_to sign_in_path
  end

  def register
    FEDERATION_REPORTER.report_registration(current_transaction, request)
    redirect_to will_it_work_for_me_path
  end
end
