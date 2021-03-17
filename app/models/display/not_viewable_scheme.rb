module Display
  NotViewableScheme = Struct.new(:scheme) do
    delegate :display_name, to: :scheme

    def viewable?
      false
    end
  end
end
