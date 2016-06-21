module Analytics
  class FederationReporter
    def initialize(federation_translator, analytics_reporter)
      @federation_translator = federation_translator
      @analytics_reporter = analytics_reporter
    end

    def report_sign_in(transaction_simple_id, request)
      report_action(transaction_simple_id, request, 'The No option was selected on the introduction page')
    end

    def report_registration(transaction_simple_id, request)
      report_action(transaction_simple_id, request, 'The Yes option was selected on the start page')
    end

    def report_idp_registration(request, idp_name, idp_name_history, evidence, recommended)
      cvars = Analytics::CustomVariable.build(:register_idp, idp_name).merge(
        Analytics::CustomVariable.build(:idp_selection, idp_name_history.join(',')))

      recommended_str = recommended ? '(recommended)' : '(not recommended)'
      list_of_evidence = evidence.sort.join(', ')
      action = "#{idp_name} was chosen for registration #{recommended_str} with evidence #{list_of_evidence}"

      @analytics_reporter.report_custom_variable(request, action, cvars)
    end

    def report_sign_in_idp_selection(request, idp_display_name)
      cvar = Analytics::CustomVariable.build(:select_idp, idp_display_name)
      @analytics_reporter.report_custom_variable(request, "Sign In - #{idp_display_name}", cvar)
    end

  private

    def report_action(transaction_simple_id, request, action)
      begin
        transaction_analytics_description =
          @federation_translator.translate("rps.#{transaction_simple_id}.analytics_description")
        @analytics_reporter.report_custom_variable(
          request,
          action,
          Analytics::CustomVariable.build(:rp, transaction_analytics_description))
      rescue Display::FederationTranslator::TranslationError => e
        Rails.logger.warn e
      end
    end
  end
end
