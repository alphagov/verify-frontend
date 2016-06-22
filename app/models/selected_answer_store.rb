class SelectedAnswerStore
  def initialize(session)
    @session = session
  end

  def store_selected_answers(stage, answers)
    selected_answers[stage] = answers
  end

  def selected_answers
    @session[:selected_answers] ||= {}
  end

  def selected_evidence
    answers_hash = selected_answers.values.reduce(:merge)
    if answers_hash.nil?
      []
    else
      as_evidence_array(answers_hash)
    end
  end

  def selected_evidence_for(stage)
    answers_hash = selected_answers.fetch(stage, {})
    as_evidence_array(answers_hash)
  end

private

  def as_evidence_array(hash)
    hash.select { |_, value| value }.keys.map(&:to_sym)
  end
end
