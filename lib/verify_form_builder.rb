class VerifyFormBuilder < ActionView::Helpers::FormBuilder
  # Our custom radio / checkbox implementation
  def custom_radio_button key, value, text, attributes = {}
    input = radio_button key, value, attributes
    label = label "#{key}_#{value.to_s.parameterize}", text
    "<div class=\"multiple-choice\">#{input} #{label}</div>".html_safe
  end

  def custom_check_box key, attributes, true_value, false_value, text
    input = check_box key, attributes, true_value, false_value
    label = label key, text
    "<div class=\"multiple-choice\">#{input} #{label}</div>".html_safe
  end
end
