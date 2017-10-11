module RoutesHelper
  ReportToPiwik = ->(experiment_name, reported_alternative, transaction_id, request) {
    AbTest.report(experiment_name, reported_alternative, transaction_id, request)
  }
end
