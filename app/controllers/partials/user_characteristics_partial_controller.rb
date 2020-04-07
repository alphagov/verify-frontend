module UserCharacteristicsPartialController
  def selected_answer_store
    @selected_answer_store ||= SelectedAnswerStore.new(session)
  end

  def selected_evidence
    selected_answer_store.selected_evidence
  end

  def set_device_type_evidence
    selected_answer_store.store_selected_answers("device_type", device_type)
  end
end
