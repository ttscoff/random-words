# frozen_string_literal: true

module RandomWords
  class ::Array
    # Split a terminators array into terminators and
    # extended punctuation based on a line without a comma
    # @param terminators [Array<String>] An array of
    #   terminator strings
    #
    # @return [Array<Array<String>>]
    #   An array containing two arrays: the first for terminators
    #   and the second for extended punctuation
    def split_terminators
      terminators = []
      extended_punctuation = []
      terminators_ended = false
      each do |line|
        if line.include?(',') && !terminators_ended
          terminators << line.split(',').map(&:strip)
        elsif terminators_ended
          extended_punctuation << line.split(',').map(&:strip)
        else
          terminators_ended = true
        end
      end
      terminators.delete_if { |line| line[1].empty? }
      extended_punctuation.delete_if { |line| line[1].empty? }
      [terminators, extended_punctuation]
    end

    # Returns a random word from the array.
    #
    # @return [String] A random word.
    def random_word
      sample
    end

    # Returns a random word from the array.
    #
    # @return [String] A random word.
    def random_word!
      sample!
    end
  end
end