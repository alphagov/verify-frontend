class FurtherInformationService
  def initialize(session_proxy, cycle_three_display_data_repo)
    @session_proxy = session_proxy
    @cycle_three_display_data_repo = cycle_three_display_data_repo
  end

  def fetch(cookies)
    attribute_key = @session_proxy.cycle_three_attribute_name(cookies)
    @cycle_three_display_data_repo.fetch(attribute_key)
  end

  def submit(cookies, value)
    @session_proxy.submit_cycle_three_value(cookies, value)
  end

  def cancel(cookies)
    @session_proxy.cycle_three_cancel(cookies)
  end
end
