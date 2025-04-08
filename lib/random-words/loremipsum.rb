#!/usr/bin/env ruby
# frozen_string_literal: true

# Random Sentence Generator
# This script generates random sentences using a variety of words and structures.
# It includes nouns, verbs, adjectives, adverbs, articles, clauses, and more.
class RandomWords
  attr_accessor :nouns, :verbs, :passive_verbs, :adverbs, :adjectives, :articles, :clauses, :subordinate_conjunctions,
                :terminators, :numbers, :plural_nouns, :plural_verbs, :length, :paragraph_length, :plural_articles
  attr_reader :source

  SENTENCE_PARTS = %w[random_article random_adjective random_noun random_adverb random_verb random_adjective
                      random_verb random_adverb].freeze

  def initialize(source = nil)
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
    @length = :medium
    @paragraph_length = 5
    lengths
  end

  def source=(new_source)
    initialize(new_source)
  end

  # Refactored lengths and lengths= methods
  def lengths
    @lengths ||= { short: 60, medium: 200, long: 300, very_long: 500 }
  end

  def lengths=(new_lengths)
    @lengths = lengths.merge(new_lengths)
  end

  # Optimized words method
  def words(number)
    result = SENTENCE_PARTS.cycle.take(number).map { |part| send(part.to_sym) }
    result.join(' ').compress.strip
  end

  # Improved characters method
  def characters(min, max = nil, whole_words: true, dead_switch: 0)
    result = ''
    max ||= min

    current_part = 0
    while result.length < max
      break if result.length >= min

      dead_switch += 1
      word = send(SENTENCE_PARTS[current_part].to_sym)
      current_part = (current_part + 1) % SENTENCE_PARTS.length

      new_result = "#{result} #{word}".strip
      compressed_length = new_result.gsub(/\s+/, ' ').length

      if compressed_length < min
        result = new_result
        next
      elsif compressed_length > max
        needed = max - result.gsub(/\s+/, ' ').length - 1
        options = nouns_of_length(needed)
        return "#{result} #{options.sample}".gsub(/\s+/, ' ') unless options.empty?

        if whole_words && dead_switch < 20
          return characters(min, max, whole_words: whole_words,
                                      dead_switch: dead_switch)
        end

        truncated = new_result[0...max].strip
        return truncated if truncated.length >= min

        return truncated.terminate * (min - truncated.length)
      end

      result = new_result
    end

    result.strip.terminate * [0, min - result.length].max
  end

  def sentence
    generate_combined_sentence
  end

  def sentences(number)
    Array.new(number) { generate_combined_sentence }
  end

  def generate_combined_sentence
    sentence = generate_sentence
    return sentence.capitalize.terminate.compress if sentence.length > define_length(@length)

    while sentence.length < define_length(@length)
      # Generate a random number of sentences to combine
      new_sentence = generate_sentence(define_length(@length) / 2)

      # Combine the sentences with random conjunctions
      sentence = "#{sentence.strip}, #{random_conjunction} #{new_sentence}"
    end

    sentence.capitalize.terminate.compress
  end

  def generate_sentence(length = nil)
    length ||= define_length(@length)
    sentence_components = []

    # Randomly decide if we include a plural noun with a number
    sentence_components << random_number_with_plural if rand < 0.2 # 20% chance to include a plural noun

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

  def paragraph(length = @paragraph_length)
    sentences = []
    length.times do
      sentences << generate_combined_sentence
    end
    sentences.join(' ').strip.compress
  end

  private

  # Improved error handling for from_file
  def from_file(filename)
    filename = "#{filename.sub(/\.txt$/, '')}.txt"
    path = File.join(__dir__, 'words', @source.to_s, filename)

    path = File.join(__dir__, 'words', 'english', filename) unless File.exist?(path)

    File.read(path).split("\n").map(&:strip) # Changed from split_lines to split("\n")
  rescue Errno::ENOENT
    warn "File not found: #{filename}"
    []
  end

  def define_length(length)
    case length
    when :short
      @lengths[:short] || 60
    when :medium
      @lengths[:medium] || 120
    when :long
      @lengths[:long] || 200
    when :very_long
      @lengths[:very_long] || 300
    else
      raise ArgumentError, "Invalid length: #{length}. Use :short, :medium, or :long."
    end
  end

  def nouns_of_length(length)
    nouns.select { |word| word.length == length }
  end

  def random_noun_with_length(length)
    nouns_of_length(length).sample
  end

  def random_conjunction
    %w[and or but].sample
  end

  def random_number_with_plural
    plural_noun = plural_nouns.sample
    number = numbers.sample
    "#{number} #{plural_noun}"
  end

  def random_noun
    nouns.sample
  end

  def random_verb
    verbs.sample
  end

  def random_plural_verb
    plural_verbs.sample
  end

  def random_passive_verb
    passive_verbs.sample
  end

  def random_adverb
    adverbs.sample
  end

  def random_adjective
    adjectives.sample
  end

  def random_article
    articles.sample
  end

  def random_article_for_noun(noun)
    article = plural_nouns.include?(noun) ? random_plural_article : random_article
    if noun.start_with?(/[aeiou]/i) && article =~ /^an?$/
      article = 'an' if article == 'a'
    elsif article == 'an'
      article = 'a'
    end
    article
  end

  def random_plural_article
    plural_articles.sample
  end

  def random_clause
    clauses.sample
  end

  def random_subordinate_conjunction
    subordinate_conjunctions.sample
  end

  # Refactored generate_main_clause
  def generate_main_clause
    beginning = if rand < 0.5
                  "#{random_number_with_plural} #{random_adverb} #{random_plural_verb}"
                else
                  noun = random_noun
                  "#{random_article_for_noun(noun)} #{random_adjective} #{noun} #{random_adverb} #{random_verb}"
                end

    tail = rand < 0.5 ? ", #{random_clause}" : ''
    "#{beginning.strip}#{tail.strip}"
  end

  # Simplified generate_additional_clauses
  def generate_additional_clauses
    Array.new(rand(1..2)) { random_clause }
  end

  # Added helper method for compressing and stripping
  def compress_and_strip(text)
    text.gsub(/\s+/, ' ').strip
  end

  def generate_word
    word_parts = []
    word_parts << random_article if rand < 0.5
    word_parts << random_adjective if rand < 0.5
    word_parts << random_noun if rand < 0.5
    word_parts << random_verb if rand < 0.5
    word_parts << random_adverb if rand < 0.5

    word_parts.compact.join(' ')
  end
end
