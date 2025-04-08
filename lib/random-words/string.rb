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
  # @return [String] The string with a random punctuation mark at the end.
  # @example
  #   "Hello World".terminate # => "Hello World."
  #
  def terminate
    terminators = %w[. . . ! ! ?]
    terminator = terminators.sample
    sub(/[.!?]*$/, terminator)
  end
end
