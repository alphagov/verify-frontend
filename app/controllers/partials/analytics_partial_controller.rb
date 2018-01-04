module AnalyticsPartialController
  def public_piwik
    PUBLIC_PIWIK
  end

  def report_to_analytics(action_name)
    FEDERATION_REPORTER.report_action(current_transaction, request, action_name)
  end

  def set_piwik_custom_variables
    @piwik_custom_variables = [
      Analytics::CustomVariable.build_for_js_client(:rp, current_transaction.analytics_description),
      Analytics::CustomVariable.build_for_js_client(:loa_requested, session[:requested_loa])
    ]
  end
end
