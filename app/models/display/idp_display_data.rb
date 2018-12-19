module Display
  class IdpDisplayData < DisplayData
    def prefix
      "idps"
    end

    content :name
    content :about
    content :requirements
    content :contact_details
    content :tagline, default: nil
    content :special_no_docs_instructions_html, default: ''
    content :no_docs_requirement, default: ''
    content :interstitial_question, default: ''
    content :interstitial_explanation, default: ''
    content :mobile_app_installation, default: ''

    alias_method :about_content, :about
    alias_method :display_name, :name
    alias_method :special_no_docs_instructions, :special_no_docs_instructions_html
  end
end
