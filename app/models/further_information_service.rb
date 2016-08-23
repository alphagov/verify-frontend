class FurtherInformationService
  def initialize(session_proxy, cycle_three_attribute_repo)
    @session_proxy = session_proxy
    @cycle_three_attribute_repo = cycle_three_attribute_repo
  end

  def get_attribute_for_session(session_id)
    attribute_key = @session_proxy.cycle_three_attribute_name(session_id)
    @cycle_three_attribute_repo.fetch(attribute_key)
  end

  def submit(session_id, value)
    @session_proxy.submit_cycle_three_value(session_id, value)
  end

  def cancel(session_id)
    @session_proxy.cycle_three_cancel(session_id)
  end
end
