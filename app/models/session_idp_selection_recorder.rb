class SessionIdpSelectionRecorder
  attr_reader :idp_names

  def initialize(idp_names, max_idps: 5)
    @idp_names = idp_names
    @max_idps = max_idps
    @idps_truncated = false
  end

  def idp_selected(idp_name)
    unless idp_names.include?(idp_name)
      if idp_names.count == @max_idps
        @idps_truncated = true
      else
        @idp_names << idp_name
      end
    end
  end

  def idp_string
    result = @idp_names.to_a.join(', ')
    result << "...TRUNCATED" if @idps_truncated
    result
  end
end
