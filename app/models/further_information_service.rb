class FurtherInformationService
  def initialize(session_proxy, cycle_three_attribute_repo)
    @session_proxy = session_proxy
    @cycle_three_attribute_repo = cycle_three_attribute_repo
  end

  def get_attribute_for_session(session, cookies)
    attribute_key = @session_proxy.cycle_three_attribute_name(session, cookies)
    @cycle_three_attribute_repo.fetch(attribute_key)
  end

  def submit(session, cookies, value)
    @session_proxy.submit_cycle_three_value(session, cookies, value)
  end

  def cancel(session, cookies)
    @session_proxy.cycle_three_cancel(session, cookies)
  end
end
