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
      each do |line|
        if line =~ /\w +\w/
          first_names_ended = true
          last_names_ended = true
        end

        if line.strip =~ /^[\w\-'’"“”]+$/ && !first_names_ended
          first_names << line
        elsif first_names_ended
          if line.strip =~ /^[\w\-'’"“”]+$/ && !last_names_ended
            last_names << line
          elsif last_names_ended
            full_names << line
          else
            last_names_ended = true
          end
        else
          first_names_ended = true
        end
      end
      first_names.delete_if(&:empty?)
      last_names.delete_if(&:empty?)
      full_names.delete_if(&:empty?)
      [first_names, last_names, full_names]
    end
  end
end
