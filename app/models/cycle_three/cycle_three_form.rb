module CycleThree
  class CycleThreeForm
    include ::ActiveModel::Model

    attr_reader :cycle_three_data

    validate :matches_regex

    def initialize(hash)
      @cycle_three_data = hash[:cycle_three_data]
    end


    def self.model_name
      ActiveModel::Name.new(self, nil, 'cycle_three_form')
    end

    def pattern
      raise NotImplementedError
    end

    def sanitised_cycle_three_data
      @cycle_three_data.gsub(/[^a-zA-Z0-9]/, '').upcase
    end

    def allows_nullable?
      false
    end

  private

    def matches_regex
      unless pattern.match(@cycle_three_data)
        errors.add(
          :cycle_three_data,
          'hub.further_information.attribute_validation_message'
        )
      end
    end
  end
end
