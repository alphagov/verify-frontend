module RedirectWithSeeOther
  def redirect_to(options = {}, response_status = {})
    response_status.reverse_merge! status: :see_other
    super options, response_status
  end
end
