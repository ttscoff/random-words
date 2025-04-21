# frozen_string_literal: true

module RandomWords
  # Array helpers for RandomWords
  # This module extends the Array class with additional methods for manipulating arrays.
  class ::Array
    # Split a terminators array into terminators and
    # extended punctuation based on a line without a comma
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

    # Split a names list into first and last names
    # Splits the names at blank line into two arrays: first names and last names.
    # @return [Array<Array<String>, Array<String>>]
    def split_names
      first_names = []
      last_names = []
      full_names = []
      first_names_ended = false
      last_names_ended = false

      sections = [[]]
      idx = 0
      each do |line|
        if line.strip.empty? || line !~ /^[[:word:]]/i
          idx += 1
          sections[idx] = []
        else
          sections[idx] << line.strip
        end
      end

      if sections.length == 1
        first_names = []
        last_names = []
        full_names = sections[0]
      elsif sections.length == 2
        first_names = sections[0]
        last_names = sections[1]
        full_names = []
      else
        first_names = sections[0]
        last_names = sections[1]
        full_names = sections[2]
      end

      first_names.delete_if(&:empty?)
      last_names.delete_if(&:empty?)
      full_names.delete_if(&:empty?)
      [first_names, last_names, full_names]
    end

    def rotate
      return self if empty?

      # Rotate the array by moving the first element to the end
      first_element = shift
      push(first_element)
      self
    end
  end
end
