module ApplicationHelper
  def feedback_source
    content_for(:feedback_source) || ""
  end
end
