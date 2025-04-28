# frozen_string_literal: true

module RandomWords
  # @!visibility private
  # This class is used to convert boolean values to strings, integers, and floats.
  # It also provides a method to check if the value is truish.
  class ::FalseClass
    # Convert a boolean value to a string.
    # @return [String] "true" or "false"
    def to_s
      'false'
    end

    # Convert a boolean value to an integer.
    # @return [Integer] 1 for true, 0 for false
    def to_i
      0
    end

    # Convert a boolean value to a float.
    # @return [Float] 1.0 for true, 0.0 for false
    def to_f
      0.0
    end

    # Shim for truish
    # @return [Boolean] false
    def trueish?
      false
    end
  end

  # @!visibility private
  # This class is used to convert boolean values to strings, integers, and floats.
  # It also provides a method to check if the value is truish.
  class ::TrueClass
    # Convert a boolean value to a string.
    # @return [String] "true" or "false"
    def to_s
      'true'
    end

    # Convert a boolean value to an integer.
    # @return [Integer] 1 for true, 0 for false
    def to_i
      1
    end

    # Convert a boolean value to a float.
    # @return [Float] 1.0 for true, 0.0 for false
    def to_f
      1.0
    end

    # Shim for truish
    def trueish?
      true
    end
  end
end
