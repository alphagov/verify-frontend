module Analytics
  class NullReporter
    def report_custom_variable(*args); end

    def report(*args); end

    def report_to_piwik(*args); end

    def report_event(*args); end

    def report_action(*arg); end

    def headers(*args); end
  end
end
