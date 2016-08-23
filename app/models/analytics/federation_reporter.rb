module Analytics
  class FederationReporter
    def initialize(analytics_reporter)
      @analytics_reporter = analytics_reporter
    end

    def report_sign_in(current_transaction, request)
      report_action(current_transaction, request, 'The No option was selected on the introduction page')
    end

    def report_registration(current_transaction, request)
      report_action(current_transaction, request, 'The Yes option was selected on the start page')
    end

    def report_idp_registration(request, idp_name, idp_name_history, evidence, recommended, index, num_of_idps)
      cvars = Analytics::CustomVariable.build(:register_idp, idp_name).merge(
        Analytics::CustomVariable.build(:idp_selection, idp_name_history.join(',')))

      recommended_str = recommended ? '(recommended)' : '(not recommended)'
      list_of_evidence = evidence.sort.join(', ')
      action = "#{idp_name} was chosen for registration #{recommended_str} (index #{index || '-'} of #{num_of_idps || '-'}) with evidence #{list_of_evidence}"

      @analytics_reporter.report_custom_variable(request, action, cvars)
    end

    def report_sign_in_idp_selection(request, idp_display_name)
      cvar = Analytics::CustomVariable.build(:select_idp, idp_display_name)
      @analytics_reporter.report_custom_variable(request, "Sign In - #{idp_display_name}", cvar)
    end

    def report_cycle_three(request, attribute)
      cvar = Analytics::CustomVariable.build(:cycle_three_attribute, attribute)
      @analytics_reporter.report_custom_variable(request, 'Cycle3 submitted', cvar)
    end

    def report_cycle_three_cancel(current_transaction, request)
      report_action(current_transaction, request, 'Matching Outcome - Cancelled Cycle3')
    end

  private

    def report_action(current_transaction, request, action)
      begin
        @analytics_reporter.report_custom_variable(
          request,
          action,
          Analytics::CustomVariable.build(:rp, current_transaction.analytics_description))
      rescue Display::FederationTranslator::TranslationError => e
        Rails.logger.warn e
      end
    end
  end
end
