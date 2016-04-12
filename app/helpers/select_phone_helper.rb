module SelectPhoneHelper
  def form_question_class
    flash[:errors] ? 'form-group error' : 'form-group'
  end

  def hidden_form_question_class
    [form_question_class, 'js-hidden'].join(' ')
  end
end
