module ApplicationHelper
  def feedback_source
    content_for(:feedback_source) || ""
  end

  def piwik_custom_url
    uri_from_base(content_for(:piwik_custom_path))
  end

  def piwik_custom_url?
    content_for?(:piwik_custom_path)
  end

  def piwik_noscript_query_string
    hash = {
        idsite: public_piwik.site_id,
        rec: 1,
        rand: Random.rand(2**32 - 1),
        action_name: "#{content_for(:page_title_in_english)} - GOV.UK Verify - GOV.UK",
    }
    hash[:url] = piwik_custom_url if piwik_custom_url?
    hash.to_query
  end

  def uri_from_base(path)
    URI.join(request.base_url, path)
  end

  def form_question_class
    flash[:errors] ? 'form-group error' : 'form-group'
  end

  def hidden_form_question_class
    [form_question_class, 'panel', 'panel-border-narrow', 'js-hidden'].join(' ')
  end

  def fingerprint_path
    FINGERPRINT_CONFIG
  end

  def idp_tagline(identity_provider)
    identity_provider.display_name + (identity_provider.tagline.nil? ? '' : ": #{identity_provider.tagline}")
  end
end
