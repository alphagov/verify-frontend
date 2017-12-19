require 'ab_test/ab_test'

class StartController < ApplicationController
  layout 'slides'
  before_action :set_device_type_evidence

  def index
    @form = StartForm.new({})
    FEDERATION_REPORTER.report_start_page(current_transaction, request)
    render :start
  end

  def request_post
    @form = StartForm.new(params['start_form'] || {})
    if @form.valid?
      if @form.registration?
        register
      else
        FEDERATION_REPORTER.report_sign_in(current_transaction, request)
        redirect_to sign_in_path
      end
    else
      flash.now[:errors] = @form.errors.full_messages.join(', ')
      render :start
    end
  end

  def register
    FEDERATION_REPORTER.report_registration(current_transaction, request)
    redirect_to about_path
  end
end
