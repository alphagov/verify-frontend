require "spec_helper"
require "models/analytics/federation_reporter"
require "analytics"
require "logger_helper"
require "errors/warning_level_error"

module Analytics
  describe FederationReporter do
    let(:analytics_reporter) { double(:analytics_reporter) }
    let(:federation_reporter) { FederationReporter.new(analytics_reporter) }
    let(:request) { double(:request) }
    let(:current_transaction) { double("current transaction", simple_id: "test-rp") }
    let(:transaction_description) { "description" }

    before(:each) do
      allow(request).to receive(:session).and_return(requested_loa: "LEVEL_2")
      allow(current_transaction).to receive(:analytics_description).and_return(transaction_description)
    end

    describe "#report_sign_in_idp_selection" do
      it "should build correct report" do
        idp_display_name = "IDCorp"
        expect(analytics_reporter).to receive(:report_action)
                                        .with(
                                          request,
                                          "Sign In - #{idp_display_name}",
                                          1 => %w(RP description),
                                          2 => %w(LOA_REQUESTED LEVEL_2),
                                        )

        federation_reporter.report_sign_in_idp_selection(current_transaction, request, idp_display_name)
      end
    end

    describe "#report_idp_registration" do
      idp_name = "IDCorp"
      idp_history = ["Previous IdP", "IDCorp"]
      idp_history_str = idp_history.join(",")

      it "should report correctly when an IDP is selected for registration" do
        expect(analytics_reporter).to receive(:report_action)
                                        .with(
                                          request,
                                          "#{idp_name} was chosen for registration",
                                          1 => %w(RP description),
                                          2 => %w(LOA_REQUESTED LEVEL_2),
                                          5 => ["IDP_SELECTION", idp_history_str],
                                        )

        federation_reporter.report_idp_registration(
          current_transaction: current_transaction,
          request: request,
          idp_name: idp_name,
          idp_name_history: idp_history,
        )
      end

      it "should sort evidence" do
        expect(analytics_reporter).to receive(:report_action)
                                        .with(
                                          request,
                                          "#{idp_name} was chosen for registration",
                                          1 => %w(RP description),
                                          2 => %w(LOA_REQUESTED LEVEL_2),
                                          5 => ["IDP_SELECTION", idp_history_str],
                                        )

        federation_reporter.report_idp_registration(
          current_transaction: current_transaction,
          request: request,
          idp_name: idp_name,
          idp_name_history: idp_history,
        )
      end

      it "should report default IDP history to the chosen IDP" do
        expect(analytics_reporter).to receive(:report_action)
                                        .with(
                                          request,
                                          "#{idp_name} was chosen for registration",
                                          1 => %w(RP description),
                                          2 => %w(LOA_REQUESTED LEVEL_2),
                                          5 => ["IDP_SELECTION", idp_name],
                                        )

        federation_reporter.report_idp_registration(
          current_transaction: current_transaction,
          request: request,
          idp_name: idp_name,
          idp_name_history: nil,
        )
      end
    end

    describe "#report_user_idp_attempt" do
      idp_name = "IDCorp"
      attempt_number = "1"

      it "should report attempt correctly when idp selected if first registration" do
        expect(analytics_reporter).to receive(:report_action)
                                        .with(
                                          request,
                                          "ATTEMPT_#{attempt_number} | registration | test-rp | #{idp_name} |#{FederationReporter::HINT_NOT_PRESENT}",
                                          1 => %w(RP description),
                                          2 => %w(LOA_REQUESTED LEVEL_2),
                                        )

        federation_reporter.report_user_idp_attempt(
          current_transaction: current_transaction,
          request: request,
          idp_name: idp_name,
          attempt_number: "1",
          journey_type: "registration",
          hint_followed: nil,
        )
      end

      it "should report attempt correctly when journey hint is set but the user selected registration" do
        expect(analytics_reporter).to receive(:report_action)
                                        .with(
                                          request,
                                          "ATTEMPT_#{attempt_number} | registration | test-rp | #{idp_name} |#{FederationReporter::HINT_NOT_FOLLOWED}",
                                          1 => %w(RP description),
                                          2 => %w(LOA_REQUESTED LEVEL_2),
                                        )

        federation_reporter.report_user_idp_attempt(
          current_transaction: current_transaction,
          request: request,
          idp_name: idp_name,
          attempt_number: "1",
          journey_type: "registration",
          hint_followed: false,
        )
      end

      it "should report attempt correctly when the user followed the journey hint" do
        expect(analytics_reporter).to receive(:report_action)
                                        .with(
                                          request,
                                          "ATTEMPT_#{attempt_number} | sign-in | test-rp | #{idp_name} |#{FederationReporter::HINT_FOLLOWED}",
                                          1 => %w(RP description),
                                          2 => %w(LOA_REQUESTED LEVEL_2),
                                        )

        federation_reporter.report_user_idp_attempt(
          current_transaction: current_transaction,
          request: request,
          idp_name: idp_name,
          attempt_number: "1",
          journey_type: "sign-in",
          hint_followed: true,
        )
      end

      it "should report single IDP journey correctly" do
        expect(analytics_reporter).to receive(:report_action)
                                        .with(
                                          request,
                                          "ATTEMPT_#{attempt_number} | single-idp | test-rp | #{idp_name} |#{FederationReporter::HINT_NOT_FOLLOWED}",
                                          1 => %w(RP description),
                                          2 => %w(LOA_REQUESTED LEVEL_2),
                                        )

        federation_reporter.report_user_idp_attempt(
          current_transaction: current_transaction,
          request: request,
          idp_name: idp_name,
          attempt_number: "1",
          journey_type: "single-idp",
          hint_followed: false,
        )
      end
    end

    describe "#report_user_idp_outcome" do
      idp_name = "IDCorp"
      attempt_number = "1"
      response_status = "SUCCESS"

      it "should report outcome correctly on response from first registration" do
        hint_followed = nil
        expect(analytics_reporter).to receive(:report_action)
                                        .with(
                                          request,
                                          "OUTCOME_#{attempt_number} | registration | test-rp | #{idp_name} |#{FederationReporter::HINT_NOT_PRESENT} #{response_status} |",
                                          1 => %w(RP description),
                                          2 => %w(LOA_REQUESTED LEVEL_2),
                                        )

        federation_reporter.report_user_idp_outcome(
          current_transaction: current_transaction,
          request: request,
          idp_name: idp_name,
          attempt_number: "1",
          journey_type: "registration",
          hint_followed: hint_followed,
          response_status: "SUCCESS",
        )
      end
    end

    describe "#report_external_ab_test" do
      before(:each) do
        transaction = double
        allow(transaction).to receive(:analytics_description).and_return("description")
      end

      it "should report an ab test custom variable" do
        alternative_name = "alternative_name"
        expect(analytics_reporter).to receive(:report_action)
                                        .with(
                                          request,
                                          "The user has started an external AB test",
                                          6 => ["AB_TEST", alternative_name],
                                        )

        federation_reporter.report_external_ab_test(request, alternative_name)
      end
    end

    describe "#report_cycle_three" do
      it "should report cycle 3 attribute name" do
        attribute_name = "anAttribute"
        expect(analytics_reporter).to receive(:report_action)
                                        .with(
                                          request,
                                          "Cycle3 submitted",
                                          1 => %w(RP description),
                                          2 => %w(LOA_REQUESTED LEVEL_2),
                                          4 => ["CYCLE_3", attribute_name],
                                        )

        federation_reporter.report_cycle_three(current_transaction, request, attribute_name)
      end
    end

    describe "#report_cycle_three_cancel" do
      it "should report cycle 3 cancelled" do
        expect(analytics_reporter).to receive(:report_action)
                                        .with(
                                          request,
                                          "Matching Outcome - Cancelled Cycle3",
                                          1 => %w(RP description),
                                          2 => %w(LOA_REQUESTED LEVEL_2),
                                        )

        federation_reporter.report_cycle_three_cancel(current_transaction, request)
      end
    end

    describe "#report_sign_in" do
      it "should report sign in journey" do
        expect(analytics_reporter).to receive(:report_action)
                                        .with(
                                          request,
                                          "The user started a sign-in journey",
                                          1 => %w(RP description),
                                          2 => %w(LOA_REQUESTED LEVEL_2),
                                          3 => %w(JOURNEY_TYPE SIGN_IN),
                                        )

        federation_reporter.report_sign_in(current_transaction, request)
      end
    end

    describe "#report_registration" do
      it "should report registration journey" do
        expect(analytics_reporter).to receive(:report_action)
                                        .with(
                                          request,
                                          "The user started a registration journey",
                                          1 => %w(RP description),
                                          2 => %w(LOA_REQUESTED LEVEL_2),
                                          3 => %w(JOURNEY_TYPE REGISTRATION),
                                        )

        federation_reporter.report_registration(current_transaction, request)
      end
    end

    describe "#report_started_single_idp_journey" do
      it "should report a single idp journey" do
        expect(analytics_reporter).to receive(:report_action)
                                        .with(
                                          request,
                                          "The user has started a single idp journey",
                                          3 => %w(JOURNEY_TYPE SINGLE_IDP),
                                        )

        federation_reporter.report_started_single_idp_journey(request)
      end
    end

    describe "#report_sign_in_journey_ignored" do
      it "should report that the sign in hint was ignored" do
        idp_name = "stub-idp"
        expect(analytics_reporter).to receive(:report_action)
                                        .with(
                                          request,
                                          "HINT_DELETED | sign-in | test-rp | #{idp_name}",
                                          1 => %w(RP description),
                                          2 => %w(LOA_REQUESTED LEVEL_2),
                                        )

        federation_reporter.report_sign_in_journey_ignored(current_transaction, request, idp_name)
      end
    end
  end
end
