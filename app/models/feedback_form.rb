class FeedbackForm
  include ActiveModel::Model

  attr_reader :what, :details, :reply, :name, :email, :referer, :user_agent, :js_disabled
  validate :mandatory_fields_present

  private

  def mandatory_fields_present
    if what.blank? || details.blank?
      errors.set(:base, [I18n.t('hub.feedback.errors.no_selection')])
    end
  end

end
