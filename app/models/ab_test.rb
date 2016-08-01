class ABTest
  def initialize(alternatives)
    @alternatives = alternatives
    @total = @alternatives.values.inject(:+).to_f
  end

  def get_ab_test_cookie(random)
    random = (random * @total).round
    @alternatives.each do |name, weight|
      return name.to_s if random < weight
      random -= weight
    end
  end
end
