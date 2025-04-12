#!/usr/bin/env ruby
# frozen_string_literal: true

# String extensions for RandomWords
# This module extends the String class with additional methods for cleaning,
# compressing, and manipulating strings.
#
# @example
#   str = "  Hello, World!  "
#   str.clean # => "Hello World"
#   str.compress # => "Hello World"
#   str.terminate # => "Hello World."
#
class ::String
  # Remove unwanted characters and whitespace from a string.
  # @return [String] The string with unwanted characters removed.
  # @example
  #   "Hello, World!".clean # => "Hello World"
  #
  # @return [String] The cleaned string.
  def clean
    gsub(/[^-a-zA-Z0-9\s]/, '').strip
  end

  # Captialize instances of "i" in a string.
  # @return [String] The string with "i" capitalized.
  # @example
  #   "this is an i".capitalize_i # => "this is an I"
  # @example
  #   "this is an iPhone".capitalize_i # => "this is an iPhone"
  #
  def capitalize_i
    gsub(/\bi\b/, 'I')
  end

  # Capitalize the first letter of a string.
  # @return [String] The string with the first letter capitalized.
  # @example
  #  "hello world".capitalize # => "Hello world"
  def capitalize
    letters = split('')
    string = []
    while letters[0] =~ /[:word:]/
      string << letters.shift
    end
    string << letters.shift.upcase
    string.concat(letters)
    string.join("")
  end

  # Remove duplicate commas
  # @return [String] The string with duplicate commas removed.
  # @example
  #  "Hello, , World!".remove_duplicate_commas # => "Hello, World!"
  def dedup_commas
    gsub(/(, +)+/, ',').gsub(/,/, ', ')
  end

  # Generate a sentence with capitalization and terminator
  # @param terminator [Array<String>] An array of beginning and ending punctuation marks.
  # @return [String] The string with a random punctuation mark at the end.
  def to_sent(terminator)
    capitalize.compress.capitalize_i.dedup_commas.terminate(terminator)
  end

  # Split a string by newlines, clean each line, and remove empty lines.
  # @return [Array<String>] The string split into lines, cleaned, and empty lines removed.
  # @example
  #   "Hello, World!\n\nThis is a test.".split_lines # => ["Hello World", "This is a test"]
  #
  def split_lines
    strip.split("\n").map(&:clean).reject(&:empty?)
  end

  # Compress multiple spaces into a single space and remove leading/trailing spaces.
  # @return [String] The string with extra spaces compressed.
  def compress
    gsub(/\s+/, ' ').strip
  end

  # Terminate a string with a random punctuation mark.
  # @param terminator [Array<String>] An array of beginning and ending punctuation marks.
  # @return [String] The string with a random punctuation mark at the end.
  # @example
  #   "Hello World".terminate(["", "."]) # => "Hello World."
  #
  def terminate(terminator)
    sub(/^[a-z0-9]*/, terminator[0]).sub(/[^a-z0-9]*$/i, terminator[1])
  end

  # Remove any punctuation mark from the end of a string.
  # @return [String] The string with the last punctuation mark removed.
  def no_term
    sub(/[.!?;,-]*$/, '')
  end
end
