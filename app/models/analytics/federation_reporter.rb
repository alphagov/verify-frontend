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

  private

    def report_action(transaction_simple_id, request, action)
      begin
        transaction_analytics_description =
          @federation_translator.translate("rps.#{transaction_simple_id}.analyticsDescription")
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
