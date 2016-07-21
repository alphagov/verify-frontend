module CycleThree
  class CycleThreeAttribute
    include ::ActiveModel::Model

    attr_reader :cycle_three_data

    validate :matches_regex

    def initialize(hash)
      @cycle_three_data = hash[:cycle_three_data]
    end


    def self.model_name
      ActiveModel::Name.new(self, nil, 'cycle_three_attribute')
    end

    def pattern
      raise NotImplementedError
    end

    def sanitised_cycle_three_data
      @cycle_three_data.gsub(/[^a-zA-Z0-9]/, '').upcase
    end

    def self.allows_nullable?
      false
    end

    def allows_nullable?
      self.class.allows_nullable?
    end

    def self.display_data
      raise NotImplementedError
    end

    def display_data
      self.class.display_data
    end

    def simple_id
      self.class.simple_id
    end

    delegate :name, :field_name, :help_to_find, :example, to: :display_data

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
