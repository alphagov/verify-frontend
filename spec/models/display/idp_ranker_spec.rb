require 'display/idp_ranker'

module Display
  describe IdpRanker do
    let(:ranker) {
      IdpRanker.new([
        { 'profile' => %w(doc1 doc2), 'rank' => %w(idpA idpB idpC) },
        { 'profile' => ['doc1'], 'rank' => %w(idpC idpA idpD) },
        { 'profile' => %w(doc2 doc3), 'rank' => %w(idpX idpY) }])
    }

    it 'should rank idps based on evidence' do
      ranking = ranker.rank([:doc2, :doc3])

      expect(ranking.idps).to eq(%w(idpX idpY))
    end

    it 'should rank idps based on evidence regardless of order' do
      ranking = ranker.rank([:doc3, :doc2])

      expect(ranking.idps).to eq(%w(idpX idpY))
    end

    it 'should return nil if no ranking found' do
      ranking = ranker.rank([:doc3, :doc1])

      expect(ranking.idps).to eql []
    end
  end

  describe IdpRanking do
    it 'should rank idp based on ranking' do
      ranking = IdpRanking.new([:idpA, :idpC, :idpB])

      expect(ranking.rank_idp(:idpA)).to eql 0
      expect(ranking.rank_idp(:idpB)).to eql 2
      expect(ranking.rank_idp(:idpC)).to eql 1
    end

    it 'should rank idp last if it doesnt appar in rakings' do
      ranking = IdpRanking.new([:idpA, :idpC, :idpB])

      expect(ranking.rank_idp(:idpX)).to eql 3
      expect(ranking.rank_idp(:idpY)).to eql 3
    end
  end
end
