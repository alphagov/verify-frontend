class StartForm
  include ActiveModel::Model

  attr_reader :selection
  validate :answer_required

  def initialize(hash)
    @selection = hash[:selection]
  end

private

  def answer_required
    if @selection.blank?
      errors.set(:base, [I18n.t('hub.start.error_message')])
    end
  end
end
