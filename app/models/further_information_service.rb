class FurtherInformationService
  def initialize(policy_proxy, cycle_three_attribute_repo)
    @policy_proxy = policy_proxy
    @cycle_three_attribute_repo = cycle_three_attribute_repo
  end

  def get_attribute_for_session(session_id)
    attribute_key = @policy_proxy.cycle_three_attribute_name(session_id)
    @cycle_three_attribute_repo.fetch(attribute_key)
  end

  def submit(session_id, value)
    @policy_proxy.submit_cycle_three_value(session_id, value)
  end

  def cancel(session_id)
    @policy_proxy.cycle_three_cancel(session_id)
  end
end
