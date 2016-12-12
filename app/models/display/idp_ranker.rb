
module Display
  class IdpRanker
    def initialize(rankings)
      @rankings = rankings.inject({}) do |acc, ranking|
        profile = ranking['profile'].map(&:to_sym).to_set
        acc[profile] = IdpRanking.new(ranking['rank'])
        acc
      end
    end

    def rank(evidence)
      @rankings.fetch(evidence.to_set, IdpRanking.no_ordering)
    end
  end

  class IdpRanking
    attr_reader :idps

    def initialize(idps)
      @idps = idps
    end

    def self.no_ordering
      IdpRanking.new([])
    end

    def rank_idp(idp)
      @idps.find_index(idp) || @idps.size
    end

    def has_rank?
      !idps.empty?
    end
  end
end
