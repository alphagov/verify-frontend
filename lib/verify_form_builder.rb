class VerifyFormBuilder < ActionView::Helpers::FormBuilder
  # Our custom radio button implementation. Workarounds:
  # 1. empty onclick attribute for iOS5 support
  # 2. blank space in the inner span to let JAWS-on-IE read the following text
  def block_label key, value, text, attributes = {}
    label "#{key}_#{value.to_s.parameterize}", class: 'block-label', onclick: '' do
      radio = radio_button key, value, attributes
      "#{radio} <span><span class=\"inner\">&nbsp;</span></span> #{text}".html_safe
    end
  end
end
