class StartForm
  include ActiveModel::Model

  attr_reader :selection
  validate :answer_required

  def initialize(hash)
    @selection = hash[:selection]
  end

  def registration?
    self.selection == 'true'
  end

private

  def answer_required
    if @selection.blank?
      errors.add(:base, [I18n.t('hub.start_loa2.error_message')])
    end
  end
end
