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

  def uri_from_base(path)
    URI.join(request.base_url, path)
  end
end
