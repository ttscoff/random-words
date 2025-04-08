#!/usr/bin/env ruby
# frozen_string_literal: true

# Random Sentence Generator
# This script generates random sentences using a variety of words and structures.
# It includes nouns, verbs, adjectives, adverbs, articles, clauses, and more.
module RandomWords
  # Random character, word, and sentence generator
  class Generator
    # @return [Array<String>] arrays of elements of speech
    attr_accessor :nouns, :verbs, :passive_verbs, :adverbs, :adjectives, :articles, :clauses, :subordinate_conjunctions,
                  :terminators, :numbers, :plural_nouns, :plural_verbs, :plural_articles

    # @return [Integer] Lengths
    attr_accessor :sentence_length, :paragraph_length

    # @return [Symbol] Dictionary in use
    attr_reader :source

    # Define the default sentence parts
    # These parts will be used to generate random sentences and character strings
    SENTENCE_PARTS = %w[random_article random_adjective random_noun random_adverb random_verb random_adjective
                        random_verb random_adverb].freeze

    # Initialize the generator with a source and options
    # @param source [Symbol] The source of the words (e.g., :english)
    # @param _options [Hash] Options for the generator (e.g., length, paragraph_length)
    # @example
    #   generator = RandomWords::Generator.new(:english, sentence_length: :medium, paragraph_length: 5)
    #   generator.source = :french
    #   generator.lengths = { short: 50, medium: 150 }
    #   generator.sentence_length = :long
    #   generator.paragraph_length = 3
    def initialize(source = nil, _options = {})
      @source = source || :english
      @nouns = from_file('nouns-singular.txt')
      @plural_nouns = from_file('nouns-plural.txt')
      @verbs = from_file('verbs-singular.txt')
      @plural_verbs = from_file('verbs-plural.txt')
      @passive_verbs = from_file('verbs-passive.txt')
      @adverbs = from_file('adverbs.txt')
      @adjectives = from_file('adjectives.txt')
      @articles = from_file('articles-singular.txt')
      @plural_articles = from_file('articles-plural.txt')
      @clauses = from_file('clauses.txt')
      @subordinate_conjunctions = from_file('conjunctions-subordinate.txt')

      @numbers = from_file('numbers.txt')

      @options = {
        sentence_length: :medium,
        paragraph_length: 5
      }
      @options.merge!(_options) if _options.is_a?(Hash)
      lengths
    end

    # Bad init method for testing purposes
    # @!visibility private
    def bad_init
      @nouns = from_file('nouns-noent.txt')
    end

    # define all lengths for testing purposes
    # @!visibility private
    def define_all_lengths
      @lengths = {
        short: 60,
        medium: 200,
        long: 300,
        very_long: 500
      }
      res = []
      res << define_length(:short)
      res << define_length(:medium)
      res << define_length(:long)
      res << define_length(:very_long)
      res
    end

    # Define a bad length for testing purposes
    # @!visibility private
    def bad_length
      define_length(:bad_length)
    end

    # Test random generators
    # These methods are used to test the random generation of words and sentences
    # @!visibility private
    def test_random
      res = []
      res << random_noun
      res << random_verb
      res << random_adjective
      res << random_adverb
      res << random_article
      res << random_article_for_noun('apple')
      res << random_article_for_noun('apples')
      res << random_article_for_noun('banana')
      res << random_article_for_noun('bananas')
      res << random_plural_article
      res << random_clause
      res << random_subordinate_conjunction
      res << random_number_with_plural
      res << random_conjunction
      res << random_passive_verb
      res << random_plural_noun
      res << random_plural_verb
      res << generate_additional_clauses.join(' ')
      res
    end

    # Define a new source dictionary and re-initialize
    def source=(new_source)
      initialize(new_source)
    end

    # Refactored lengths and lengths= methods
    # This method returns the lengths of sentences
    # The default lengths are set to the following values:
    # short: 60, medium: 200, long: 300, very_long: 500
    def lengths
      @lengths ||= { short: 60, medium: 200, long: 300, very_long: 500 }
    end

    # This method allows you to set new lengths for the sentences
    # It merges the new lengths with the existing ones
    # Example: lengths = { short: 50, medium: 150 }
    # @param new_lengths [Hash] A hash containing the new lengths for the sentences
    # @return [Hash] The updated lengths hash
    # @example
    #   lengths = { short: 50, medium: 150 }
    def lengths=(new_lengths)
      @lengths = lengths.merge(new_lengths)
    end

    # Generate a random word
    # @return [String] A randomly generated word
    def word
      generate_word
    end

    # Generate a set number of random words
    # @param number [Integer] The number of words to generate
    def words(number)
      result = SENTENCE_PARTS.cycle.take(number).map { |part| send(part.to_sym) }.take(number)
      result.map do |word|
        word.split(/ /).last
      end.join(' ').compress
    end

    # Generate a series of random words up to a specified length
    # @param min [Integer] The minimum length of the generated string
    # @param max [Integer] (Optional) The maximum length of the generated string
    # @param whole_words [Boolean] (Optional) Whether to generate whole words or not
    # @param dead_switch [Integer] (Optional) A counter to prevent infinite loops
    # @return [String] The generated string of random words
    # @example
    #   characters(50) # Generates a string with at least 50 characters
    #   characters(50, 100) # Generates a string with between 50 and 100 characters
    #   characters(50, whole_words: false) # Generates a string with 50 characters allowing word truncation
    def characters(min, max = nil, whole_words: true, dead_switch: 0)
      result = ''
      max ||= min
      raise ArgumentError, 'Infinite loop detected' if dead_switch > 20

      current_part = 0
      while result.length < max && result.length < min
        word = send(SENTENCE_PARTS[current_part].to_sym)
        current_part = (current_part + 1) % SENTENCE_PARTS.length
        new_result = "#{result} #{word}".compress

        return handle_overflow(OverflowConfig.new(new_result, result, min, max, whole_words, dead_switch)) if new_result.length > max
        return new_result if new_result.length == max

        result = new_result
      end

      result.strip
    end

    # Generate a random sentence
    # @param length [Integer] The desired length of the sentence in characters
    # @return [String] A randomly generated sentence
    def sentence(length = nil)
      generate_combined_sentence(length)
    end

    # Generate a specified number of random sentences
    # @param number [Integer] The number of sentences to generate
    # @return [Array] An array of generated sentences
    # @example
    #   sentences(5) # Generates an array of 5 random sentences
    def sentences(number)
      Array.new(number) { generate_combined_sentence }
    end

    # Generate a random sentence, combining multiple sentences if necessary
    # @param length [Symbol] The desired length of the sentence, :short, :medium, :long, or :very_long
    # @return [String] A randomly generated sentence
    # This method generates a random sentence and checks its length.
    # If the length is less than the defined length, it combines it with another sentence.
    # The final sentence is returned with proper capitalization and termination.
    # @example
    #   generate_combined_sentence # Generates a combined sentence
    def generate_combined_sentence(length = nil)
      length ||= define_length(@options[:sentence_length])
      sentence = generate_sentence
      return sentence.capitalize.terminate.compress if sentence.length > length

      while sentence.length < length
        # Generate a random number of sentences to combine
        new_sentence = generate_sentence(length / 2)

        # Combine the sentences with random conjunctions
        sentence = "#{sentence.strip}, #{random_conjunction} #{new_sentence}"
      end

      sentence.capitalize.terminate.compress
    end

    # Generate a random paragraph
    # @param length [Integer] The desired number of sentences in the paragraph
    # @return [String] A randomly generated paragraph
    # This method generates a random paragraph by combining multiple sentences.
    # It uses the generate_combined_sentence method to create each sentence.
    # @see #generate_combined_sentence
    def paragraph(length = @options[:paragraph_length])
      sentences = []
      length.times do
        sentences << generate_combined_sentence
      end
      sentences.join(' ').strip.compress
    end

    private

    # Handle overflow when the new result exceeds the maximum length
    OverflowConfig = Struct.new(:new_result, :result, :min, :max, :whole_words, :dead_switch)

    def handle_overflow(config)
      needed = config.max - config.result.compress.length - 1
      config.min = config.max if config.min > config.max
      if needed > 1
        options = nouns_of_length(needed)
        return "#{config.result} #{options.sample}".compress unless options.empty?
      end

      if config.whole_words
        return characters(config.min, config.max, whole_words: config.whole_words, dead_switch: config.dead_switch + 1)
      end

      truncated = config.new_result.compress[0...config.max]
      truncated.strip if truncated.strip.length.between?(config.min, config.max)
    end

    # Generate a random sentence with a specified length
    # @param length [Integer] The desired length of the sentence
    # @return [String] A randomly generated sentence
    # This method generates a random sentence with a specified length.
    # It has a 20% chance of including a random number with a plural noun and a main clause.
    # The sentence is constructed using various components such as nouns, verbs, adjectives, and adverbs.
    # @example
    #   generate_sentence(100) # Generates a sentence with a length of 100 characters
    #   generate_sentence # Generates a sentence with the default length
    def generate_sentence(length = nil)
      length ||= define_length(@options[:sentence_length])
      sentence_components = []

      # Randomly decide if we include a plural noun with a number
      sentence_components << random_number_with_plural if roll(20) # 20% chance to include a plural noun

      # Construct main clause
      sentence_components << generate_main_clause

      # Include any additional clauses
      # sentence_components.concat(generate_additional_clauses)

      # while sentence_components.join(' ').strip.length < length
      #   # Randomly include a subordinate conjunction
      #   additional_clauses = generate_additional_clauses
      #   sentence_components.concat(additional_clauses)
      #   sentence_components.map!(&:strip)
      #   break if sentence_components.join(' ').length >= length

      #   conjunction = random_subordinate_conjunction.strip
      #   sentence_components.unshift(conjunction.capitalize) # Place conjunction at the start
      # end

      # Join all parts into a single sentence
      sentence_components.join(' ').strip.compress
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
      path = File.join(__dir__, 'words', @source.to_s, filename)

      path = File.join(__dir__, 'words', 'english', filename) unless File.exist?(path)

      File.read(path).split("\n").map(&:strip) # Changed from split_lines to split("\n")
    rescue Errno::ENOENT
      warn "File not found: #{filename}"
      []
    end

    # Convert a length symbol to a specific length value
    # @param length [Symbol] The length symbol (:short, :medium, :long, or :very_long)
    # @return [Integer] The corresponding length value
    # @example
    #  define_length(:short) # Returns the length for :short
    def define_length(length)
      case length
      when :short
        @lengths[:short] || 60
      when :medium
        @lengths[:medium] || 200
      when :long
        @lengths[:long] || 300
      when :very_long
        @lengths[:very_long] || 500
      else
        raise ArgumentError, "Invalid length: #{length}. Use :short, :medium, or :long."
      end
    end

    # Get a list of nouns matching a specific length
    # @param length [Integer] The desired length of the nouns
    # @return [Array] An array of nouns with the specified length
    # @example
    #  nouns_of_length(5) # Returns an array of nouns with a length of 5 characters
    def nouns_of_length(length)
      nouns.select { |word| word.length == length }
    end

    # Generate a random conjunction
    # @return [String] A randomly selected conjunction
    # @example
    #  random_conjunction # Returns a random conjunction
    def random_conjunction
      %w[and or but].sample
    end

    # Generate a random number with a plural noun
    # @return [String] A string containing a number and a plural noun
    # Number names will be sourced from the numbers.txt file and provided in written not numeric form
    # @example
    #   random_number_with_plural # Returns a string like "three cats"
    def random_number_with_plural
      number = numbers.sample
      "#{number} #{random_plural_noun}"
    end

    # Generate a random noun
    # @return [String] A randomly selected noun
    def random_noun
      nouns.sample
    end

    # Generate a random plural noun
    # @return [String] A randomly selected plural noun
    def random_plural_noun
      plural_nouns.sample
    end

    # Generate a random verb
    # @return [String] A randomly selected verb
    def random_verb
      verbs.sample
    end

    # Generate a random plural verb
    # @return [String] A randomly selected plural verb
    def random_plural_verb
      plural_verbs.sample
    end

    # Generate a random passive verb
    # @return [String] A randomly selected passive verb
    def random_passive_verb
      passive_verbs.sample
    end

    # Generate a random adverb
    # @return [String] A randomly selected adverb
    def random_adverb
      adverbs.sample
    end

    # Generate a random adjective
    # @return [String] A randomly selected adjective
    def random_adjective
      adjectives.sample
    end

    # Generate a random article
    # @return [String] A randomly selected article
    def random_article
      articles.sample
    end

    # Generate a random article for a noun
    # @param noun [String] The noun for which to generate an article
    # @return [String] A randomly selected article for the given noun
    # This method checks if the noun is plural and selects an appropriate article.
    # If the noun starts with a vowel, it uses 'an' instead of 'a'.
    # @example
    #   random_article_for_noun('apple') # Returns 'an'
    def random_article_for_noun(noun)
      article = plural_nouns.include?(noun) ? random_plural_article : random_article
      if noun.start_with?(/[aeiou]/i) && article =~ /^an?$/
        article = 'an' if article == 'a'
      elsif article == 'an'
        article = 'a'
      end
      article
    end

    # Generate a random plural article
    # @return [String] A randomly selected plural article
    def random_plural_article
      plural_articles.sample
    end

    # Generate a random clause
    # @return [String] A randomly selected clause
    def random_clause
      clauses.sample
    end

    # Generate a random subordinate conjunction
    # @return [String] A randomly selected subordinate conjunction
    def random_subordinate_conjunction
      subordinate_conjunctions.sample
    end

    # Generate a random main clause
    # @return [String] A randomly generated main clause
    # This method constructs a main clause using a random number of words.
    # It randomly selects a noun, verb, adjective, and adverb to create a "coherent" sentence.
    # It has a 50% chance of including a random number with a plural noun.
    # It has a 20% chance of including a random clause at the end.
    # @example
    #   generate_main_clause # Returns a random main clause
    def generate_main_clause
      beginning = if roll(50)
                    "#{random_number_with_plural} #{random_adverb} #{random_plural_verb}"
                  else
                    noun = random_noun
                    "#{random_article_for_noun(noun)} #{random_adjective} #{noun} #{random_adverb} #{random_verb}"
                  end

      tail = roll(20) ? ", #{random_clause}" : ''
      "#{beginning.strip}#{tail.strip}"
    end

    # Simplified generate_additional_clauses
    def generate_additional_clauses
      Array.new(rand(1..2)) { random_clause }
    end

    # Roll a random number to determine if an action should occur
    # @param percent [Integer] 1-100 percent chance of the action occurring (1-100)
    # @return [Boolean] True if the action occurs, false otherwise
    # @example
    #   roll(50) # 50% chance of returning true
    def roll(percent)
      rand(1..100) <= percent
    end

    # Generate a random word
    # @return [String] A randomly generated word
    # This method constructs a random word using various components such as articles, adjectives, nouns, verbs, and adverbs.
    # It randomly decides whether to include each component based on a 50% chance.
    # @example
    #   generate_word # Returns a random word
    def generate_word
      send(SENTENCE_PARTS.sample)
    end
  end
end
