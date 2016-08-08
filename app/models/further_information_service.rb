class FurtherInformationService
  def initialize(session_proxy, cycle_three_attribute_repo)
    @session_proxy = session_proxy
    @cycle_three_attribute_repo = cycle_three_attribute_repo
  end

  def get_attribute_for_session(cookies)
    attribute_key = @session_proxy.cycle_three_attribute_name(cookies)
    @cycle_three_attribute_repo.fetch(attribute_key)
  end

  def submit(cookies, value)
    @session_proxy.submit_cycle_three_value(cookies, value)
  end

  def cancel(cookies)
    @session_proxy.cycle_three_cancel(cookies)
  end
end
