class HintsMapper
  ANSWER_TO_HINT_MAPPING = {
    'mobile_phone' => 'mobile',
    'smart_phone' => 'apps',
    'landline' => 'landline',
    'passport' => 'ukpassport',
    'driving_licence' => 'ukphotolicence',
    'non_uk_id_document' => 'nonukid'
  }.freeze

  def self.map_answers_to_hints(answers_hash)
    result = Set.new
    answers = answers_hash.values.reduce(:merge)
    unless answers.nil?
      answers.each do |key, value|
        hint = create_hint(key, value)
        result << hint unless hint.nil?
      end
    end
    result
  end

  private_class_method

  def self.create_hint(evidence_name, answer)
    hint_suffix = ANSWER_TO_HINT_MAPPING[evidence_name]
    hint_prefix = answer ? 'has_' : 'not_'
    hint_prefix + hint_suffix unless hint_suffix.nil?
  end
end
