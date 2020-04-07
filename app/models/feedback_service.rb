class FeedbackService
  def initialize(zendesk_client, default_email)
    @zendesk_client = zendesk_client
    @default_email = default_email
  end

  def submit!(session_id, form)
    ticket = {
               subject: subject(form),
               comment: { value: comment_value(session_id, form) },
               requester: { name: presented_name(form), email: presented_email(form) },
             }
    @zendesk_client.submit(session_id, ticket)
  end

private

  ERROR_MESSAGE_TEMPLATE = %{User feedback received

What were you trying to do?
<%= form.what %>

Please provide details of your question, problem or feedback:
<%= form.details %>

session id: <%= session_id %>

From page: <%= form.referer %>

User agent: <%= form.user_agent %>

Javascript enabled: <%= form.js_enabled? %>

From user: <%= presented_name(form) %>
With email: <%= presented_email(form) %>
}.freeze

  def comment_value(session_id, form)
    ERB.new(ERROR_MESSAGE_TEMPLATE).result(binding)
  end

  def subject(form)
    form.reply_required? ? "[GOV.UK Verify] Enquiry" : "[GOV.UK Verify] Feedback"
  end

  def presented_name(form)
    form.reply_required? ? form.name : ""
  end

  def presented_email(form)
    form.reply_required? ? form.email : @default_email
  end
end
