require "rails_helper"
require "feedback_form"

describe FeedbackService do
  let(:form) { instance_double("FeedbackForm") }
  let(:zendesk_client) { double("ZendeskClient") }
  let(:session_id) { "sessionid" }
  let(:email) { "bob@email.com" }
  let(:referer) { "some-referer" }
  let(:name) { "Bob" }
  let(:user_agent) { "some-user-agent" }
  let(:js_enabled) { true }
  let(:what) { "some-what" }
  let(:details) { "some-details" }
  let(:default_email) { "baz@email.com" }
  let(:feedback_service) { FeedbackService.new(zendesk_client, default_email) }

  let(:feedback_comment_value) {
    %{User feedback received

What were you trying to do?
#{what}

Please provide details of your question, problem or feedback:
#{details}

session id: #{session_id}

From page: #{referer}

User agent: #{user_agent}

Javascript enabled: #{js_enabled}

From user:\s
With email: #{default_email}
}
  }

  let(:enquiry_comment_value) {
    %{User feedback received

What were you trying to do?
#{what}

Please provide details of your question, problem or feedback:
#{details}

session id: #{session_id}

From page: #{referer}

User agent: #{user_agent}

Javascript enabled: #{js_enabled}

From user: #{name}
With email: #{email}
}
  }

  it "will use the feedback form to submit an Enquiry ticket to zendesk" do
    expect(form).to receive(:name).and_return(name).twice
    expect(form).to receive(:email).and_return(email).twice
    expect(form).to receive(:referer).and_return(referer)
    expect(form).to receive(:user_agent).and_return(user_agent)
    expect(form).to receive(:js_enabled?).and_return(js_enabled)
    expect(form).to receive(:what).and_return(what)
    expect(form).to receive(:details).and_return(details)
    expect(form).to receive(:reply_required?).and_return(true).exactly(5).times


    expected_ticket = {
                        subject: "[GOV.UK Verify] Enquiry",
                        comment: { value: enquiry_comment_value },
                        requester: { name: name, email: email },
                      }
    expect(zendesk_client).to receive(:submit).with(session_id, expected_ticket).and_return true


    expect(feedback_service.submit!(session_id, form)).to eql(true)
  end

  it "will use the feedback form to submit an Feedback ticket to zendesk" do
    expect(form).to_not receive(:name)
    expect(form).to_not receive(:email)
    expect(form).to receive(:referer).and_return(referer)
    expect(form).to receive(:user_agent).and_return(user_agent)
    expect(form).to receive(:js_enabled?).and_return(js_enabled)
    expect(form).to receive(:what).and_return(what)
    expect(form).to receive(:details).and_return(details)
    expect(form).to receive(:reply_required?).and_return(false).exactly(5).times


    expected_ticket = {
                        subject: "[GOV.UK Verify] Feedback",
                        comment: { value: feedback_comment_value },
                        requester: { name: "", email: default_email },
                      }
    expect(zendesk_client).to receive(:submit).with(session_id, expected_ticket).and_return true

    expect(feedback_service.submit!(session_id, form)).to eql(true)
  end
end
