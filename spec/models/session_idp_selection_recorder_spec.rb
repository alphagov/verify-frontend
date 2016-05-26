class SessionIdpSelectionRecorder
  def initialize
    @idp_names = Set.new
  end

  def idp_selected(idp_name)
    @idp_names << idp_name
  end

  def idp_string
    @idp_names.to_a.join(', ')
  end
end

describe SessionIdpSelectionRecorder do
  it 'reports IdPs' do
    recorder = SessionIdpSelectionRecorder.new

    recorder.idp_selected("A")

    expect(recorder.idp_string).to eql("A")
  end
end