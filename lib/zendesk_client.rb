require 'zendesk_api'

class ZendeskClient
  def initialize(client, logger)
    @client = client
    @logger = logger
  end

  def submit(session_id, ticket)
    ticket_created = @client.tickets.create!(ticket)
    session_id = session_id.nil? ? 'session-cookie-is-null-or-invalid' : session_id
    @logger.info("Feedback sent for session id #{session_id}, zendesk with ticket id #{ticket_created.id}")
    true
  rescue ZendeskAPI::Error::ClientError => e
    # If there are multiple connect timeout / network errors when sending feedback, try checking
    # https://support.zendesk.com/hc/en-us/articles/203660846-Zendesk-Public-IP-addresses
    # and check the listed IPs there are whitelisted on our environments.
    @logger.error(e)
    false
  end
end
