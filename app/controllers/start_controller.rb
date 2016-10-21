class StartController < ApplicationController
  layout 'slides'

  def index
    @form = StartForm.new({})
    unless current_transaction_is_in_early_beta
      ab_test_cookie = cookies[CookieNames::AB_TEST]
      if ab_test_cookie.nil?
        set_ab_test_cookie(experiment_selections)
      end
      experiment_selection_hash = Cookies.parse_json(ab_test_cookie)
      if is_missing_experiments?(experiment_selection_hash)
        update_ab_test_cookie(experiment_selection_hash)
      end
    end

    reported_alternative = Cookies.parse_json(cookies[CookieNames::AB_TEST])['select_documents']
    AbTest.report('select_documents', reported_alternative, request)
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

  def is_missing_experiments?(experiment_selection_hash)
    missing_keys = ::AB_TESTS.keys - experiment_selection_hash.keys
    !missing_keys.empty?
  end

  def current_transaction_is_in_early_beta
    RP_CONFIG.fetch('demo_period_blacklist').include?(current_transaction_simple_id)
  end

  def set_ab_test_cookie(value)
    cookies[CookieNames::AB_TEST] = { value: value.to_json, expires: 2.weeks.from_now }
  end

  def experiment_selections
    AB_TESTS.inject({}) do |hash, (experiment_name, ab_test)|
      hash[experiment_name] = ab_test.get_ab_test_name(rand)
      hash
    end
  end

  def update_ab_test_cookie(cookies_hash)
    new_selections = experiment_selections.merge(cookies_hash)
    set_ab_test_cookie(new_selections)
  end
end
