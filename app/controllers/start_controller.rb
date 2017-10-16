class StartController < ApplicationController
  layout 'slides'

  def index
    @form = StartForm.new({})

    FEDERATION_REPORTER.report_start_page(current_transaction, request)
    if is_loa1?
      @tailored_text = current_transaction.tailored_text
      render :start_loa1
    else
      render :start_loa2
    end
  end

  # below post only hit in loa2, should be separate controller
  def request_post
    @form = StartForm.new(params['start_form'] || {})
    if @form.valid?
      if @form.registration?
        FEDERATION_REPORTER.report_registration(current_transaction, request)
        redirect_to about_path
      else
        FEDERATION_REPORTER.report_sign_in(current_transaction, request)
        redirect_to sign_in_path
      end
    else
      flash.now[:errors] = @form.errors.full_messages.join(', ')
      render :start_loa2
    end
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
