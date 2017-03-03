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

    def report_idp_registration(request, idp_name, idp_name_history, evidence, recommended)
      recommended_str = recommended ? '(recommended)' : '(not recommended)'
      list_of_evidence = evidence.sort.join(', ')
      @analytics_reporter.report_custom_variable(
        request,
        "#{idp_name} was chosen for registration #{recommended_str} with evidence #{list_of_evidence}",
        Analytics::CustomVariable.build(:idp_selection, idp_name_history.join(','))
      )
    end

    def report_loa_requested(request, loa_requested)
      @analytics_reporter.report_custom_variable(
        request, "LOA Requested - #{loa_requested}", Analytics::CustomVariable.build(:loa_requested, loa_requested)
      )
    end

    def report_sign_in_idp_selection(request, idp_display_name)
      @analytics_reporter.report(request, "Sign In - #{idp_display_name}")
    end

    def report_cycle_three(request, attribute)
      @analytics_reporter.report_custom_variable(
        request, 'Cycle3 submitted', Analytics::CustomVariable.build(:cycle_three_attribute, attribute)
      )
    end

    def report_cycle_three_cancel(current_transaction, request)
      report_action(current_transaction, request, 'Matching Outcome - Cancelled Cycle3')
    end

    def report_loa_achieved(request, loa_achieved)
      @analytics_reporter.report_custom_variable(
        request, "LOA Achieved - #{loa_achieved}", Analytics::CustomVariable.build(:loa_achieved, loa_achieved)
      )
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
