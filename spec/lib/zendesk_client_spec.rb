require "spec_helper"
require "zendesk_client"

describe ZendeskClient do
  let(:client) { double("ZendeskAPI::Client") }
  let(:tickets) { instance_double("ZendeskAPI::Collection") }
  let(:ticket) { double(:ticket) }
  let(:ticket_created) { double(:ticket_created, id: 1) }
  let(:session_id) { "1234" }
  let(:stub_logger) { double(:logger) }
  let(:zendesk_client) { ZendeskClient.new(client, stub_logger) }

  it "will return true on successful ticket creation" do
    expect(client).to receive(:tickets).and_return(tickets)
    allow(stub_logger).to receive(:info)

    expect(tickets).to receive(:create!).with(ticket).and_return ticket_created
    expect(zendesk_client.submit(session_id, ticket)).to eql(true)
  end

  it "will return false on unsuccessful ticket creation" do
    expect(client).to receive(:tickets).and_return(tickets)
    allow(stub_logger).to receive(:error)

    expect(tickets).to receive(:create!).with(ticket).and_raise ZendeskAPI::Error::ClientError.new("Errr")
    expect(zendesk_client.submit(session_id, ticket)).to eql(false)
  end

  it "should log ticket id on successful creation" do
    expect(client).to receive(:tickets).and_return(tickets)
    ticket_id = "12345"
    expect(tickets).to receive(:create!).with(ticket).and_return(ticket_created)
    expect(ticket_created).to receive(:id).and_return(ticket_id)
    expected_log_message = "Feedback sent for session id #{session_id}, zendesk with ticket id #{ticket_id}"
    expect(stub_logger).to receive(:info).with(expected_log_message).once

    zendesk_client.submit(session_id, ticket)
  end

  it "should log error on unsuccessful creation" do
    expect(client).to receive(:tickets).and_return(tickets)
    error = ZendeskAPI::Error::ClientError.new("bbhmm")
    expect(tickets).to receive(:create!).with(ticket).and_raise error
    expect(stub_logger).to receive(:error).with(error)

    zendesk_client.submit(session_id, ticket)
  end

  it "should still log if session id is null" do
    expect(client).to receive(:tickets).and_return(tickets)
    ticket_created = double("ticket")
    expect(tickets).to receive(:create!).with(ticket).and_return(ticket_created)
    ticket_id = "12345"
    expect(ticket_created).to receive(:id).and_return(ticket_id)
    expected_log_message = "Feedback sent for session id session-cookie-is-null-or-invalid, zendesk with ticket id #{ticket_id}"
    expect(stub_logger).to receive(:info).with(expected_log_message).once

    zendesk_client.submit(nil, ticket)
  end
end
