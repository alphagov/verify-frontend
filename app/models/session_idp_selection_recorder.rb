class SessionIdpSelectionRecorder
  attr_reader :idp_names

  def initialize(idp_names, max_idps: 5)
    @idp_names = idp_names
    @max_idps = max_idps
  end

  def idp_selected(idp_name)
    @idp_names << idp_name unless idp_names.count >= @max_idps
  end

  def idp_string
    result = @idp_names.to_a.join(', ')
    result << '...TRUNCATED' if idp_names.count >= @max_idps
    result
  end
end
