class VerifyFormBuilder < ActionView::Helpers::FormBuilder
  # Our custom radio / checkbox implementation. Workarounds:
  # 1. empty onclick attribute for iOS5 support
  # 2. blank space in the inner span to let JAWS-on-IE read the following text
  def custom_radio_button key, value, text, attributes = {}
    label "#{key}_#{value.to_s.parameterize}", class: 'block-label', onclick: '' do
      input = radio_button key, value, attributes
      "#{input} <span><span class=\"inner\">&nbsp;</span></span> #{text}".html_safe
    end
  end

  def custom_check_box key, attributes, true_value, false_value, text
    label key, class: 'block-label', onclick: '' do
      input = check_box key, attributes, true_value, false_value
      "#{input} <span><span class=\"inner\">&nbsp;</span></span> #{text}".html_safe
    end
  end
end
