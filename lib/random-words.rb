#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'yaml'

require_relative 'random-words/version'
require_relative 'random-words/string'
require_relative 'random-words/hash'
require_relative 'random-words/array'
require_relative 'random-words/boolean'
require_relative 'random-words/numeric'
require_relative 'random-words/source'
require_relative 'random-words/config'
require_relative 'random-words/generator'
require_relative 'random-words/number-to-word'
require_relative 'random-words/lorem-html'
require_relative 'random-words/html2markdown'
require_relative 'random-words/terminal'

# Main module for RandomWords
module RandomWords
  # Main class for RandomWords
  class << self
    # @!visibility private
    attr_accessor :testing, :tested

    # @!visibility private
    # Initialize the RandomWords module
    def initialize!(testing = false)
      @testing ||= testing
      @tested ||= []
    end
  end

  initialize!
end
