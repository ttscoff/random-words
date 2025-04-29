# !/usr/bin/env ruby
# frozen_string_literal: true

# Random Sentence Generator
# This script generates random sentences using a variety of words and structures.
# It includes nouns, verbs, adjectives, adverbs, articles, clauses, and more.
module RandomWords
  # Random character, word, and sentence generator
  class Generator
    # @return [Array<String>] arrays of elements of speech
    attr_reader :nouns, :verbs, :passive_verbs, :adverbs, :adjectives, :articles, :clauses, :subordinate_conjunctions,
                :terminators, :numbers, :plural_nouns, :plural_verbs, :plural_articles, :prepositions, :coordinating_conjunctions,
                :all_words, :extended_punctuation, :phrases, :names

    # return [Hash] configuration
    attr_reader :config

    # Whether to use extended punctuation
    # @return [Boolean] true if extended punctuation is used, false otherwise
    attr_reader :use_extended_punctuation

    # @return [Integer] Number of sentences in paragraphs
    attr_reader :paragraph_length

    # @return [Symbol] Sentence length (:short, :medium, :long, :very_long)
    attr_reader :sentence_length

    # @return [Symbol] Dictionary in use
    attr_reader :source

    # @return [Hash<String, RandomWords::Source>] List of available sources
    attr_reader :sources

    # Debug mode
    # @return [Boolean] true if debug mode is enabled, false otherwise
    attr_accessor :debug

    # Define the default sentence parts
    # These parts will be used to generate random sentences and character strings
    SENTENCE_PARTS = %w[random_article random_adjective random_noun random_adverb random_verb random_adjective
                        random_verb random_adverb random_phrase].freeze

    # Initialize the generator with a source and options
    # @param source [Symbol] The source of the words (e.g., :english)
    # @param options [Hash] Options for the generator (e.g., length, paragraph_length)
    # @example
    #   generator = RandomWords::Generator.new(:english, sentence_length: :medium, paragraph_length: 5)
    #   generator.source = :french
    #   generator.lengths = { short: 50, medium: 150 }
    #   generator.sentence_length = :long
    #   generator.paragraph_length = 3
    def initialize(source = :english, options = {})
      @debug = options[:debug] || false
      @tested = []
      @config = RandomWords::Config.new(source)
      @source = source

      @nouns = @config.dictionary[:nouns]
      @plural_nouns = @config.dictionary[:plural_nouns]
      @verbs = @config.dictionary[:verbs]
      @plural_verbs = @config.dictionary[:plural_verbs]
      @passive_verbs = @config.dictionary[:passive_verbs]
      @adverbs = @config.dictionary[:adverbs]
      @adjectives = @config.dictionary[:adjectives]
      @articles = @config.dictionary[:articles]
      @plural_articles = @config.dictionary[:plural_articles]
      @prepositions = @config.dictionary[:prepositions]
      @clauses = @config.dictionary[:clauses]
      @coordinating_conjunctions = @config.dictionary[:coordinating_conjunctions]
      @subordinate_conjunctions = @config.dictionary[:subordinate_conjunctions]
      @numbers = @config.dictionary[:numbers]
      @sources = @config.sources
      @terminators = @config.dictionary[:terminators]
      @names = [@config.dictionary[:first_names], @config.dictionary[:last_names], @config.dictionary[:full_names]]
      @phrases = @config.dictionary[:phrases]
      @all_words = @config.dictionary[:all_words]

      @options = {
        sentence_length: :medium,
        paragraph_length: 5,
        use_extended_punctuation: false
      }

      @options.merge!(options) if options.is_a?(Hash)
      @sentence_length = @options[:sentence_length]
      @paragraph_length = @options[:paragraph_length]
      @use_extended_punctuation = @options[:use_extended_punctuation]

      @terminators.concat(@config.dictionary[:extended_punctuation]) if @use_extended_punctuation

      lengths
    end

    # Display debug message
    def dbg(msg)
      return unless @debug

      "%#{msg}%"
    end

    # Shortcut for RandomWords::Config.create_user_dictionary
    # @param title [String] The title of the user dictionary
    # @return [Symbol] The symbolized name of the dictionary
    # @example
    #   create_dictionary('my_custom_dictionary')
    def create_dictionary(title)
      @config.create_user_dictionary(title)
    end

    # Define number of sentences in paragraphs
    # @param length [Integer] The number of sentences in the paragraph
    def paragraph_length=(length)
      unless length.is_a?(Integer) && length.positive?
        raise ArgumentError,
              'Paragraph length must be a positive integer'
      end

      @paragraph_length = length
    end

    # Define sentence length
    # @param length [Symbol] :short, :medium, :long, or :very_long
    def sentence_length=(length)
      to_set = case length.to_s
               when /^s/
                 :short
               when /^m/
                 :medium
               when /^l/
                 :long
               when /^v/
                 :very_long
               else
                 raise ArgumentError, "Invalid length: #{length}. Use :short, :medium, :long, or :very_long."
               end
      @sentence_length = to_set
    end

    # define all lengths for testing purposes
    # @!visibility private
    def define_all_lengths
      @lengths = {
        short: 20,
        medium: 60,
        long: 100,
        very_long: 300
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
      RandomWords.testing = true
      @debug = true
      @use_extended_punctuation = true
      res = []
      res << random_noun
      res << random_verb
      res << random_adjective
      res << random_adverb
      res << random_article
      res << random_article_for_word('apple')
      res << random_article_for_word('apples')
      res << random_article_for_word('banana')
      res << random_article_for_word('bananas')
      res << random_plural_article
      res << random_clause
      res << random_separator
      res << random_subordinate_conjunction
      res << random_coordinating_conjunction
      res << random_number_with_plural
      res << random_phrase
      res << random_conjunction
      res << random_name
      res << random_passive_verb
      res << random_plural_noun
      res << random_plural_verb
      res << random_preposition
      res << random_prepositional_phrase
      res << random_terminator.join(' ')
      res << generate_additional_clauses.join(' ')
      res << words_of_length(5).join(' ')
      res << nouns_of_length(5).join(' ')
      res
    end

    # Define a new source dictionary and re-initialize
    def source=(new_source)
      initialize(new_source)
    end

    def use_extended_punctuation=(use_extended_punctuation)
      raise ArgumentError, 'use_extended_punctuation must be a boolean' unless [true,
                                                                                false].include?(use_extended_punctuation)

      @use_extended_punctuation = use_extended_punctuation
      @terminators.concat(@config.dictionary[:extended_punctuation]) if use_extended_punctuation
    end

    # Refactored lengths and lengths= methods
    # This method returns the lengths of sentences
    # The default lengths are set to the following values:
    # short: 20, medium: 60, long: 100, very_long: 300
    def lengths
      @lengths ||= { short: 20, medium: 60, long: 100, very_long: 300 }
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
      end.join(' ').article_agree.compress
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
    def characters(min, max = nil, whole_words: true, whitespace: true, article: true, dead_switch: 0)
      result = ''
      max ||= min
      raise ArgumentError, 'Infinite loop detected' if dead_switch > 40

      whole_words = false if dead_switch > 15

      space = whitespace ? ' ' : ''
      current_part = article ? 0 : 1
      while result.length < max && result.length < min
        word = send(SENTENCE_PARTS[current_part].to_sym)
        word = word.gsub(/ +/, '') unless whitespace
        current_part = (current_part + 1) % SENTENCE_PARTS.length
        new_result = "#{result}#{space}#{word}".compress

        if new_result.length > max
          return handle_overflow(OverflowConfig.new(new_result, result, min, max, whole_words, whitespace,
                                                    dead_switch))
        end
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
      length ||= define_length(@sentence_length)
      sentence = generate_sentence
      return sentence.to_sent(random_terminator).fix_caps(terminators).expand_debug if sentence.length > length

      while sentence.length < length
        # Generate a random number of sentences to combine
        new_sentence = generate_sentence(length / 2)

        # Combine the sentences with random conjunctions
        sentence = "#{sentence.strip.no_term(terminators)}, #{random_coordinating_conjunction} #{new_sentence.no_term(terminators)}"
      end

      sentence.to_sent(random_terminator).fix_caps(terminators).expand_debug
    end

    # Generate a random paragraph
    # @param length [Integer] The desired number of sentences in the paragraph
    # @return [String] A randomly generated paragraph
    # This method generates a random paragraph by combining multiple sentences.
    # It uses the generate_combined_sentence method to create each sentence.
    # @see #generate_combined_sentence
    def paragraph(length = @paragraph_length)
      sentences = []
      length.times do
        sentences << generate_combined_sentence
      end
      sentences.join(' ').strip.compress
    end

    # Generate a random code language
    # @return [Symbol] A randomly selected code language
    def code_lang
      code_langs = %i[python ruby swift javascript css rust go java]
      code_langs[Random.rand(code_langs.count)]
    end

    # Return random code snippet
    # @param lang [Symbol] The language of the code snippet
    # @return [String] A randomly generated code snippet
    def code_snippet(lang = nil)
      code_snippets = {
        python: %(def hello_world():\n    print("Hello, World!")),
        ruby: %(def hello_world\n  puts "Hello, World!"\nend),
        swift: %(func helloWorld() {\n    print("Hello, World!")\n}),
        javascript: %(function helloWorld() {\n    console.log("Hello, World!");\n}),
        css: %(body {\n    background-color: #f0f0f0;\n    font-family: Arial, sans-serif;\n}\nh1 {\n    color: #333;\n}),
        rust: %(fn main() {\n    println!("Hello, World!");\n}),
        go: %(package main\nimport "fmt"\nfunc main() {\n    fmt.Println("Hello, World!")\n}),
        java: %(public class HelloWorld {\n    public static void main(String[] args) {\n        System.out.println("Hello, World!");\n    }\n})
      }
      lang ||= code_lang
      code_snippets[lang.to_sym]
    end

    # Generate random markdown
    # @param settings [Hash] Settings for generating markdown
    # @return [String] A randomly generated markdown string
    def markdown(settings = {})
      input = RandomWords::LoremHTML.new(settings)
      meta = {}
      if settings[:meta_type]
        meta[:type] = settings[:meta_type]
        meta[:title] = input.title if input.title
        meta[:style] = settings[:style] || 'style.css'
        meta[:date] = Time.now.strftime('%Y-%m-%d %H:%M:%S')
      end
      RandomWords::HTML2Markdown.new(input, nil, meta).to_s
    end

    # Generate random HTML
    # @param settings [Hash] Settings for generating HTML
    # @return [String] A randomly generated HTML string
    def html(settings = {})
      html = RandomWords::LoremHTML.new(settings)
      if settings[:complete]
        style = settings[:style] || 'style.css'
        <<~EOOUTPUT
          <!DOCTYPE html>
          <html lang="en">
          <head>
          \t<meta charset="UTF-8">
          \t<meta name="viewport" content="width=device-width, initial-scale=1.0">
          \t<title>#{html.title}</title>
          \t<link rel="stylesheet" href="#{style}">
          </head>
          <body>
            #{html.output.indent("\t")}
          </body>
          </html>
        EOOUTPUT
      else
        html.output
      end
    end

    # Generate a random name
    # @return [String] A randomly generated name
    def name
      "#{dbg('NAM')}#{random_name}"
    end

    private

    # Struct for overflow configuration
    # @!visibility private
    OverflowConfig = Struct.new(:new_result, :result, :min, :max, :whole_words, :whitespace, :dead_switch)

    # Handle overflow when the new result exceeds the maximum length
    # @param config [OverflowConfig] The configuration for handling overflow
    # @return [String] The modified result after handling overflow
    # This method checks if the new result exceeds the maximum length.
    # If it does, it tries to add a random word of the required length.
    # If the new result is still too long, it generates a new string with the specified length.
    # If the new result is shorter than the minimum length, it generates a new string with the minimum length.
    # @example
    #   handle_overflow(config) # Handles overflow for the given configuration
    # @see OverflowConfig
    # @see #characters
    # @see #words_of_length
    # @see #nouns_of_length
    def handle_overflow(config)
      space = config.whitespace ? ' ' : ''
      needed = config.max - config.result.compress.length
      needed -= space.length if needed > 0 && config.result.compress.length.positive?
      config.min = config.max if config.min > config.max
      if needed > 1
        options = words_of_length(needed)
        return "#{config.result}#{space}#{options.sample}".compress unless options.empty?
      end

      if config.whole_words
        return characters(config.min, config.max, whole_words: config.whole_words, whitespace: config.whitespace,
                                                  dead_switch: config.dead_switch + 1)
      end

      truncated = config.new_result.compress[0...config.max]
      truncated.compress.length == config.max ? truncated.compress : nil
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
      length ||= define_length(@sentence_length)
      sentence_components = []

      # Randomly decide if we include a plural noun with a number
      # sentence_components << random_number_with_plural if roll(10) # 10% chance to include a plural noun

      # Construct main clause
      sentence_components << generate_main_clause

      # Include any additional clauses
      # sentence_components.concat(generate_additional_clauses)

      while sentence_components.join(' ').strip.length < length
        # Randomly include a subordinate conjunction
        additional_clauses = generate_additional_clauses
        sentence_components.concat(additional_clauses)
        sentence_components.map!(&:strip)
        # break if sentence_components.join(' ').length >= length

        # conjunction = if roll(50) || (RandomWords.testing && !RandomWords.tested.include?('subordinate_conjunction'))
        #                 RandomWords.tested << 'subordinate_conjunction' if RandomWords.testing
        #                 random_subordinate_conjunction.strip
        #               else
        #                 RandomWords.tested << 'coordinating_conjunction' if RandomWords.testing
        #                 random_coordinating_conjunction.strip
        #               end
        # # sentence_components.unshift(conjunction.capitalize) # Place conjunction at the start
        # sentence_components << conjunction unless conjunction.empty?
      end

      # Join all parts into a single sentence
      output = sentence_components.shift
      sentence_components.each do |part|
        output << " #{roll(50) ? random_coordinating_conjunction : random_subordinate_conjunction} #{part}"
      end
      output.strip.compress
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

    # Get a list of words matching a specific length
    # @param length [Integer] The desired length of the words
    # @return [Array] An array of words with the specified length
    # @example
    #  words_of_length(5) # Returns an array of words with a length of 5 characters
    # @see #nouns_of_length
    def words_of_length(length)
      all_words.select { |word| word.length == length }
    end

    # Generate a random conjunction
    # @return [String] A randomly selected conjunction
    # @example
    #  random_conjunction # Returns a random conjunction
    def random_conjunction
      "#{dbg('COC')}#{coordinating_conjunctions.sample}"
    end

    # Generate a random number with a plural noun
    # @return [String] A string containing a number and a plural noun
    # Number names will be sourced from the numbers.txt file and provided in written not numeric form
    # @example
    #   random_number_with_plural # Returns a string like "three cats"
    def random_number_with_plural
      num = rand(1000)
      number = if roll(50)
                 num.to_word(@numbers)
               else
                 num.to_commas
               end
      if num == 1 || (RandomWords.testing && !RandomWords.tested.include?('random_noun'))
        RandomWords.tested << 'random_noun' if RandomWords.testing
        "#{dbg('NUM')}#{number} #{random_noun}"
      else
        RandomWords.tested << 'random_plural_noun' if RandomWords.testing
        "#{dbg('NUM')}#{number} #{random_plural_noun}"
      end
    end

    # Generate a random phrase
    # @return [String] A randomly selected phrase
    def random_phrase
      "#{dbg('PHR')}#{phrases.sample}"
    end

    # Generate a random noun
    # @return [String] A randomly selected noun
    def random_noun
      "#{dbg('NOU')}#{nouns.sample}"
    end

    # Generate a random plural noun
    # @return [String] A randomly selected plural noun
    def random_plural_noun
      "#{dbg('PLN')}#{plural_nouns.sample}"
    end

    # Generate a random verb
    # @return [String] A randomly selected verb
    def random_verb
      "#{dbg('VER')}#{verbs.sample}"
    end

    # Generate a random plural verb
    # @return [String] A randomly selected plural verb
    def random_plural_verb
      "#{dbg('PLV')}#{plural_verbs.sample}"
    end

    # Generate a random passive verb
    # @return [String] A randomly selected passive verb
    def random_passive_verb
      "#{dbg('PAV')}#{passive_verbs.sample}"
    end

    # Generate a random adverb
    # @return [String] A randomly selected adverb
    def random_adverb
      "#{dbg('ADV')}#{adverbs.sample}"
    end

    # Generate a random adjective
    # @return [String] A randomly selected adjective
    def random_adjective
      "#{dbg('ADJ')}#{adjectives.sample}"
    end

    # Generate a random article
    # @return [String] A randomly selected article
    def random_article
      "#{dbg('ART')}#{articles.rotate[0]}"
    end

    # Generate a random article for a noun
    # @param word [String] The noun for which to generate an article
    # @return [String] A randomly selected article for the given noun
    # This method checks if the noun is plural and selects an appropriate article.
    # If the noun starts with a vowel, it uses 'an' instead of 'a'.
    # @example
    #   random_article_for_word('apple') # Returns 'an'
    def random_article_for_word(word)
      article = plural_nouns.include?(word) ? random_plural_article : random_article
      # puts [word, article].inspect
      article = 'an' if RandomWords.testing && !RandomWords.tested.include?('random_article_for_word')
      RandomWords.tested << 'random_article_for_word' if RandomWords.testing
      if word.start_with?(/[aeiou]/i) && article =~ /^an?$/i
        article = 'an'
      elsif /^an$/i.match?(article)
        article = 'a'
      end
      article
    end

    # Generate a random plural article
    # @return [String] A randomly selected plural article
    def random_plural_article
      "#{dbg('PLA')}#{plural_articles.rotate[0]}"
    end

    # Generate a random clause
    # @return [String] A randomly selected clause
    def random_clause
      "#{dbg('CLA')}#{clauses.sample}"
    end

    # Generate a random set of separators
    def random_separators
      [',', ',', ',', ';', ':', ' —']
    end

    # Generate a random separator
    # @return [String] A randomly selected separator
    def random_separator
      "#{dbg('SEP')}#{random_separators.sample}"
    end

    # Generate a random subordinate conjunction
    # @return [String] A randomly selected subordinate conjunction
    def random_subordinate_conjunction
      "#{dbg('SUC')}#{subordinate_conjunctions.rotate[0]}"
    end

    # Generate a random coordinating conjunction
    # @return [String] A randomly selected coordinating conjunction
    def random_coordinating_conjunction
      "#{dbg('COC')}#{coordinating_conjunctions.rotate[0]}"
    end

    # Generate a random preposition
    # @return [String] A randomly selected preposition
    def random_preposition
      "#{dbg('PRE')}#{prepositions.rotate[0]}"
    end

    # Generate a random prepositional phrase
    # @return [String] A randomly generated prepositional phrase
    # This method constructs a prepositional phrase using a random preposition and a random noun.
    def random_prepositional_phrase
      preposition = random_preposition
      phrase = if roll(20) || (@testing && !@tested.include?('random_plural_article'))
                 @tested << 'random_plural_article' if @testing
                 "#{random_plural_article} #{random_number_with_plural}"
               else
                 @tested << 'random_article_for_word' if @testing
                 noun = random_noun
                 "#{random_article_for_word(noun)} #{noun}"
               end

      "#{dbg('PRP')}#{preposition} #{phrase}"
    end

    # Generate a random terminator
    # @return [Array] A randomly selected terminator pair
    def random_terminator
      terminators.sample
    end

    def random_name
      return @names[2].sample if (@names[0].empty? || @names[1].empty?) && !@names[2].empty?

      return @names[2].sample if !@names[2].empty? && roll(60)

      first_name = @names[0].sample
      middle_initial = roll(20) ? " #{('A'..'Z').to_a.sample}" : ''
      last_name = @names[1].sample
      "#{first_name}#{middle_initial} #{last_name}"
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
      beginning = case rand(10)
                  when 0..1
                    random_phrase
                  when 2..3
                    "#{random_number_with_plural} #{random_adverb} #{random_plural_verb}"
                  when 4..5
                    random_name
                  when 6..7
                    noun = random_noun
                    "#{random_adverb}, #{random_article_for_word(noun)} #{noun} #{random_verb}"
                  else
                    noun = random_noun
                    adjective = random_adjective
                    "#{random_article_for_word(adjective)} #{adjective} #{noun} #{random_adverb} #{random_verb}"
                  end
      tail = roll(50) ? " #{random_prepositional_phrase}" : ''
      separator = random_separator
      tail += roll(10) ? "#{separator} #{random_clause}" : ''
      "#{beginning.strip.sub(/[#{Regexp.escape(separator)}]*$/, separator)}#{tail}"
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
