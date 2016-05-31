require 'rails_helper'

describe SessionIdpSelectionRecorder do
  it 'reports IdPs' do
    recorder = SessionIdpSelectionRecorder.new []

    recorder.idp_selected("A")

    expect(recorder.idp_string).to eql("A")
  end

  context 'when the number of IdPs selected exceeds the number to be stored' do
    subject(:recorder) { described_class.new([], max_idps: 2) }

    it 'does not record any more IdPs' do
      %w(A B C).each { |idp_name| recorder.idp_selected(idp_name) }

      expect(recorder.idp_names).to eql(%w(A B))
    end

    it 'indicates that the list of IdPs is truncated' do
      %w(A B C).each { |idp_name| recorder.idp_selected(idp_name) }

      expect(recorder.idp_string).to eql("A, B...TRUNCATED")
    end
  end
end
