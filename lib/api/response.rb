module Api
  class Response
    include ActiveModel::Model

    def self.validated_response(hash_response)
      self.new(hash_response || {}).tap(&:validate)
    end

    def validate
      raise ModelError, self.errors.full_messages.join(", ") unless self.valid?
    end

    ModelError = Class.new(StandardError)
  end
end
