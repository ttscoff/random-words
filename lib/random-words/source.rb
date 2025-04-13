#!/usr/bin/env ruby
# frozen_string_literal: true

module RandomWords
  # A class representing a source of words for the RandomWords library.
  class Source
    attr_reader :name, :names, :config, :dictionary, :description

    # Initializes a new Source instance.
    # @param name [Symbol] The name of the source
    # @param path [String] The path to the source directory
    def initialize(name, path)
      @name = name.to_sym
      @path = path
      config = IO.read(File.join(path, 'config.yml'))
      @config = YAML.safe_load(config, aliases: true)
      @names = @config['triggers'] || [name]
      @description = @config['description'] || 'No description available'
      @dictionary = from_files
      @dictionary[:all_words] = @dictionary.values.flatten.uniq
      @dictionary[:terminators], @dictionary[:extended_punctuation] = from_file("terminators").split_terminators
    rescue StandardError
      @name = name.to_sym
      @config = {}
      @names = [name]
      @description = 'No description available'
      @dictionary = from_files
      @dictionary[:all_words] = @dictionary.values.flatten.uniq
      @dictionary[:terminators], @dictionary[:extended_punctuation] = from_file("terminators").split_terminators
    end

    # def to_sym
    #   name.to_sym
    # end

    # Bad init method for testing purposes
    # @!visibility private
    def bad_init
      from_file('nouns-noent.txt')
    end

    private

    # Load words from all dictionary files
    # @return [Hash] A hash containing arrays of words for each part of speech
    # @example
    #   from_files # Loads words from all dictionary files
    def from_files
      {
        nouns: from_file('nouns-singular'),
        plural_nouns: from_file('nouns-plural'),
        verbs: from_file('verbs-singular'),
        plural_verbs: from_file('verbs-plural'),
        passive_verbs: from_file('verbs-passive'),
        adverbs: from_file('adverbs'),
        adjectives: from_file('adjectives'),
        articles: from_file('articles-singular'),
        plural_articles: from_file('articles-plural'),
        prepositions: from_file('prepositions'),
        clauses: from_file('clauses'),
        coordinating_conjunctions: from_file('conjunctions-coordinating'),
        subordinate_conjunctions: from_file('conjunctions-subordinate'),
        numbers: from_yaml('numbers')
      }
    end

    # Load words from a dictionary file
    # Files are plain text with one word or phrase per line
    # The @source variable defines which dictionary to be used and should be defined before calling this method
    # @param filename [String] The name of the file to load
    # @return [Array] An array of words loaded from the file
    # @example
    #   from_file('nouns.txt') # Loads words from words/[source]/nouns.txt
    def from_file(filename)
      filename = "#{filename.sub(/\.txt$/, '')}.txt"
      path = File.join(@path, filename)

      File.read(path).split("\n").map(&:strip) # Changed from split_lines to split("\n")
    rescue Errno::ENOENT
      warn "File not found: #{path}"
      []
    end

    # Load words from a YAML file
    # @param filename [String] The name of the YAML file to load
    # @return [Hash] A hash of words loaded from the YAML file
    def from_yaml(filename)
      path = File.join(@path, "#{filename}.yml")
      return {} unless File.exist?(path)
      begin
        nums = YAML.safe_load(File.read(path), aliases: true).symbolize_keys
        nums.keys.each do |key|
          nums[key] = nums[key].split(" ").map(&:strip) if nums[key].is_a?(String)
        end
        nums
      rescue Psych::SyntaxError => e
        warn "YAML syntax error in #{path}: #{e.message}"
        {}
      end

    end
  end
end