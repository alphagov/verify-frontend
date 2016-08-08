class StartController < ApplicationController
  layout 'slides'

  def index
    @form = StartForm.new({})
    unless cookies[:ab_test] || current_transaction_is_in_early_beta
      cookie_value = AB_TESTS.inject({}) do |hash, (experiment_name, ab_test)|
        hash[experiment_name] = ab_test.get_ab_test_name(rand)
        hash
      end
      cookies[:ab_test] = { value: cookie_value.to_json, expires: 2.weeks.from_now }
    end
  end

  def request_post
    @form = StartForm.new(params['start_form'] || {})
    if @form.valid?
      if @form.registration?
        redirect_to about_path, status: :see_other
      else
        redirect_to sign_in_path, status: :see_other
      end
    else
      flash.now[:errors] = @form.errors.full_messages.join(', ')
      render :index
    end
  end

private

  def current_transaction_is_in_early_beta
    RP_CONFIG.fetch('demo_period_blacklist').include?(current_transaction_simple_id)
  end
end
