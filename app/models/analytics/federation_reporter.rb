module Analytics
  class FederationReporter
    AB_TEST_ACTION_NAME = 'The user has started an AB test'.freeze
    EXTERNAL_AB_TEST_ACTION_NAME = 'The user has started an external AB test'.freeze

    def initialize(analytics_reporter)
      @analytics_reporter = analytics_reporter
    end

    def report_start_page(current_transaction, request)
      report_action(
        current_transaction,
        request,
        'The user has reached the start page'
      )
    end

    def report_sign_in(current_transaction, request)
      report_action(
        current_transaction,
        request,
        'The user started a sign-in journey',
        Analytics::CustomVariable.build(:journey_type, 'SIGN_IN')
      )
    end

    def report_registration(current_transaction, request)
      report_action(
        current_transaction,
        request,
        'The user started a registration journey',
        Analytics::CustomVariable.build(:journey_type, 'REGISTRATION')
      )
    end

    def report_started_single_idp_journey(request)
      report_action_without_current_transaction(
        request,
        'The user has started a single idp journey',
        Analytics::CustomVariable.build(:journey_type, 'SINGLE_IDP')
      )
    end

    def report_unexpected_single_idp_journey(current_transaction, request, session_value, uuid)
      report_action(
        current_transaction,
        request,
        'The user unexpectedly entered the single idp journey',
        Analytics::CustomVariable.build(:session_value, session_value)
            .merge(Analytics::CustomVariable.build(:uuid, uuid))
      )
    end

    def report_ab_test(transaction_id, request, alternative_name)
      unless transaction_id.nil?
        current_transaction = RP_DISPLAY_REPOSITORY.get_translations(transaction_id)
        ab_test_custom_var = Analytics::CustomVariable.build(:ab_test, alternative_name)

        report_action(
          current_transaction,
          request,
          AB_TEST_ACTION_NAME,
          ab_test_custom_var
        )
      end
    end

    def report_external_ab_test(request, ab_test_name)
      ab_test_custom_var = Analytics::CustomVariable.build(:ab_test, ab_test_name)

      report_action_without_current_transaction(
        request,
        EXTERNAL_AB_TEST_ACTION_NAME,
        ab_test_custom_var
      )
    end

    def report_sign_in_journey_hint_shown(current_transaction, request, idp_display_name)
      report_action(
        current_transaction,
        request,
        "Sign In Journey Hint Shown - #{idp_display_name}"
      )
    end

    def report_user_idp_attempt(journey_type:, attempt_number:, current_transaction:, request:, idp_name:, user_segments:, transaction_simple_id:, hint_followed:)
      segment_list = user_segments.nil? ? 'nil' : user_segments.sort.join(', ')
      report = "ATTEMPT_#{attempt_number} | #{journey_type} | #{transaction_simple_id} | #{idp_name} | #{segment_list} |"
      report << journey_hint_details(hint_followed)
      report_action(
        current_transaction,
        request,
        report
      )
    end

    def report_user_idp_outcome(journey_type:, attempt_number:, current_transaction:, request:, idp_name:, user_segments:, transaction_simple_id:, hint_followed:, response_status:)
      segment_list = user_segments.nil? ? 'nil' : user_segments.sort.join(', ')
      report = "OUTCOME_#{attempt_number} | #{journey_type} | #{transaction_simple_id} | #{idp_name} | #{segment_list} |"
      report << journey_hint_details(hint_followed)
      report << " #{response_status} |"
      report_action(
        current_transaction,
        request,
        report
      )
    end

    def report_idp_registration(current_transaction:, request:, idp_name:, idp_name_history:, evidence:, recommended:, user_segments:)
      list_of_evidence = evidence.sort.join(', ')
      list_of_segments = user_segments.nil? ? nil : user_segments.sort.join(', ')
      report_action(
        current_transaction,
        request,
        "#{idp_name} was chosen for registration #{recommended} with segment(s) #{list_of_segments} and evidence #{list_of_evidence}",
        Analytics::CustomVariable.build(:idp_selection, idp_name_history.join(','))
      )
    end

    def report_sign_in_idp_selection(current_transaction, request, idp_display_name)
      report_action(
        current_transaction,
        request,
        "Sign In - #{idp_display_name}"
      )
    end

    def report_single_idp_journey_selection(current_transaction, request, idp_display_name)
      report_action(
        current_transaction,
        request,
        "Single IDP selected - #{idp_display_name}"
      )
    end

    def report_idp_resume_journey_selection(current_transaction, request, idp_display_name)
      report_action(
        current_transaction,
        request,
        "Resume - #{idp_display_name}"
      )
    end

    def report_sign_in_idp_selection_after_journey_hint(current_transaction, request, idp_display_name, hint_followed)
      report_action(
        current_transaction,
        request,
        "Sign In - #{idp_display_name} - Hint #{hint_followed ? 'Followed' : 'Ignored'}"
      )
    end

    def report_cycle_three(current_transaction, request, attribute)
      report_action(
        current_transaction,
        request,
        'Cycle3 submitted',
        Analytics::CustomVariable.build(:cycle_three_attribute, attribute)
      )
    end

    def report_cycle_three_cancel(current_transaction, request)
      report_action(
        current_transaction,
        request,
        'Matching Outcome - Cancelled Cycle3'
      )
    end

    def report_number_of_idps_recommended(current_transaction, request, number_of_idps_recommended)
      report_event(
        current_transaction,
        request,
        'Engagement',
        'IDPs Recommended',
        number_of_idps_recommended
      )
    end

    def report_action(current_transaction, request, action, extra_custom_vars = {})
      begin
        @analytics_reporter.report_action(
          request,
          action,
          universal_custom_variables(current_transaction, request).merge(extra_custom_vars)
        )
      rescue Display::FederationTranslator::TranslationError => e
        Rails.logger.warn e
      end
    end

    def report_action_without_current_transaction(request, action, extra_custom_vars = {})
      @analytics_reporter.report_action(
        request,
        action,
        extra_custom_vars
      )
    end

    def report_event(current_transaction, request, event_category, event_name, event_action)
      begin
        @analytics_reporter.report_event(
          request,
          universal_custom_variables(current_transaction, request),
          event_category,
          event_name,
          event_action
        )
      rescue Display::FederationTranslator::TranslationError => e
        Rails.logger.warn e
      end
    end

  private

    HINT_NOT_PRESENT = ' not present | not followed |'.freeze
    HINT_FOLLOWED = ' present | followed |'.freeze
    HINT_NOT_FOLLOWED = ' present | not followed |'.freeze

    def journey_hint_details(hint)
      return HINT_NOT_PRESENT if hint.nil?

      hint ? HINT_FOLLOWED : HINT_NOT_FOLLOWED
    end

    # The RP and LoA Requested custom variables are reported for all piwik requests.
    def universal_custom_variables(current_transaction, request)
      rp_custom_variable = Analytics::CustomVariable.build(:rp, current_transaction.analytics_description)
      loa_custom_variable = Analytics::CustomVariable.build(:loa_requested, request.session[:requested_loa])
      rp_custom_variable.merge(loa_custom_variable)
    end
  end
end
