require 'rails_helper'
require 'spec_helper'

describe LoaMatch do
  context 'LOA1' do
    it 'returns true if LEVEL_1' do
      match_result = LoaMatch::IsLoa1.call(a_request_with_loa('LEVEL_1'))

      expect(match_result).to be(true)
    end

    it 'returns false if not LEVEL_1' do
      match_result = LoaMatch::IsLoa1.call(a_request_with_loa('LEVEL_2'))

      expect(match_result).to be(false)
    end
  end

  context 'LOA2' do
    it 'returns true if LEVEL_2' do
      match_result = LoaMatch::IsLoa2.call(a_request_with_loa('LEVEL_2'))

      expect(match_result).to be(true)
    end

    it 'returns false if not LEVEL_2' do
      match_result = LoaMatch::IsLoa2.call(a_request_with_loa('LEVEL_1'))

      expect(match_result).to be(false)
    end
  end

private

  def a_request_with_loa(level)
    session = { requested_loa: level }
    LoaMatchRequestStub.new(session)
  end

  class LoaMatchRequestStub
    attr_reader :session

    def initialize(session)
      @session = session
    end
  end
end
