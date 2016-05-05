module Api
  class Response
    include ActiveModel::Model

    def validate
      raise ModelError, self.errors.full_messages.join(', ') unless self.valid?
    end

    ModelError = Class.new(StandardError)
  end
end
