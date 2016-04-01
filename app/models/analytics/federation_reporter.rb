module Analytics
  class FederationReporter
    def initialize(federation_translator, analytics_reporter)
      @federation_translator = federation_translator
      @analytics_reporter = analytics_reporter
    end

    def report_sign_in(transaction_simple_id, request)
      transaction_analytics_description = @federation_translator.translate(
        "rps.#{transaction_simple_id}.analyticsDescription")
      ANALYTICS_REPORTER.report_custom_variable(
        request,
        "The No option was selected on the introduction page #{transaction_analytics_description}",
        Analytics::CustomVariable.build(:rp, transaction_analytics_description))
    end

    def report_registration(transaction_simple_id, request)
      transaction_analytics_description =
        FEDERATION_TRANSLATOR.translate("rps.#{transaction_simple_id}.analyticsDescription")

      ANALYTICS_REPORTER.report_custom_variable(
        request,
        "The Yes option was selected on the start page #{transaction_analytics_description}",
        Analytics::CustomVariable.build(:rp, transaction_analytics_description))
    end
  end
end
