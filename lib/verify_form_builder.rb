class VerifyFormBuilder < ActionView::Helpers::FormBuilder
  # Our custom radio / checkbox implementation
  def custom_radio_button key, value, text, attributes = {}
    label "#{key}_#{value.to_s.parameterize}", class: 'block-label' do
      input = radio_button key, value, attributes
      "#{input} #{text}".html_safe
    end
  end

  def custom_check_box key, attributes, true_value, false_value, text
    label key, class: 'block-label' do
      input = check_box key, attributes, true_value, false_value
      "#{input} #{text}".html_safe
    end
  end
end
