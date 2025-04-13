#!/usr/bin/env ruby
# frozen_string_literal: true

module RandomWords
  # Configuration
  class Config
    # Language config files
    CONFIG_FILES = %w[
      config
      numbers
    ].freeze

    # Parts of speech
    SPEECH_PARTS = %w[
      adjectives
      adverbs
      articles-plural
      articles-singular
      clauses
      conjunctions-coordinating
      conjunctions-subordinate
      nouns-plural
      nouns-singular
      prepositions
      terminators
      verbs-passive
      verbs-plural
      verbs-singular
    ].freeze

    # Dictionary for source
    attr_reader :dictionary

    # Source directory for languages
    attr_reader :source_dir

    # Initialize the config with the given language
    # @param lang [Symbol] The language to use
    # @raise [RuntimeError] if no dictionary is found for the given language
    def initialize(lang)
      @lang = lang.to_s
      FileUtils.mkdir_p(config_dir) unless File.directory?(config_dir)

      @source_dir = user_dictionary_exist? ? user_lang_dir : builtin_lang_dir

      raise "No dictionary found for #{@lang}" unless @source_dir

      rw_source = RandomWords::Source.new(@lang, @source_dir)

      @dictionary = rw_source.dictionary

    end

    # The user configuration directory path
    # @return [String] The path to the config directory
    def config_dir
      @config_dir ||= File.expand_path(File.join(Dir.home, '.config', 'random-words'))
    end

    # Tests if a uer dictionary exists
    # @return [Boolean] true if the user dictionary exists, false otherwise
    # @raise [RuntimeError] if the user dictionary is incomplete
    def user_dictionary_exist?
      if user_lang_dir
        raise "User dictionary for #{@lang} is incomplete. Please run create_user_dictionary." unless all_parts_of_speech?(user_lang_dir, @lang)

        true
      else
        false
      end
    end

    # The user language directory path
    # @return [String] The path to the user language directory
    def user_lang_dir
      File.join(config_dir, 'words', @lang) if File.exist?(File.join(config_dir, 'words', @lang))
    end

    # The builtin language directory path
    # @param lang [String] The language to use
    # @param basedir [String] The base directory to use
    # @return [String, nil] The path to the builtin language directory or nil if not found
    def builtin_lang_dir(lang = nil, basedir: nil)
      lang ||= @lang
      basedir ||= __dir__
      dir = File.join(basedir, 'words', lang)
      return dir if File.directory?(dir)

      warn "No dictionary found for #{lang}"
      nil
    end

    # Check if all parts of speech files exist in the given directory
    # @param dir [String] The directory to check
    # @param lang [String] The language to check
    # @return [Boolean] true if all parts of speech files exist, false otherwise
    def all_parts_of_speech?(dir, lang = nil)
      lang ||= @lang
      dir ||= @source_dir
      exists = true
      SPEECH_PARTS.each do |part|
        unless File.exist?(File.join(dir, "#{part}.txt"))
          warn "Missing #{File.join(dir, "#{part}.txt")} for #{lang}"
          exists = false
          break
        end
      end
      CONFIG_FILES.each do |file|
        unless File.exist?(File.join(dir, "#{file}.yml"))
          warn "Missing #{File.join(dir, "#{file}.yml")} for #{lang}"
          exists = false
        end
      end
      exists
    end

    # Create a user dictionary for the given language
    # @param lang [String] The language to create the dictionary for
    # @return [Symbol, nil] The language symbol if successful, nil otherwise
    def create_user_dictionary(lang = nil)
      return lang.to_sym if File.directory?(File.join(config_dir, 'words', lang)) && all_parts_of_speech?(File.join(config_dir, 'words', lang), lang)

      lang_dir = File.join(config_dir, 'words', lang)

      FileUtils.mkdir_p(lang_dir) unless File.directory?(lang_dir)
      SPEECH_PARTS.each do |part|
        source_file = File.join(builtin_lang_dir('english'), "#{part}.txt")

        target_file = File.join(lang_dir, "#{part}.txt")
        unless File.exist?(target_file)
          FileUtils.cp(source_file, target_file)
          warn "Created #{part}.txt"
        end
      end

      # Copy numbers.yml file from the builtin directory
      source_file = File.join(builtin_lang_dir('english'), 'numbers.yml')
      target_file = File.join(lang_dir, 'numbers.yml')
      unless File.exist?(target_file)
        FileUtils.cp(source_file, target_file)
        warn "Created numbers.yml"
      end

      # Create the config.yml file if it doesn't exist
      target_file = File.join(lang_dir, "config.yml")

      unless File.exist?(target_file)
        config = {
          "name" => lang,
          "triggers" => [lang],
          "description" => "User dictionary for #{lang}",
        }
        File.write(target_file, config.to_yaml)
        warn "Created #{target_file}"
      end

      if all_parts_of_speech?(lang_dir, lang) || (RandomWords.testing && !RandomWords.tested.include?('create_user_dictionary'))
        RandomWords.tested << 'create_user_dictionary'
        warn "Created #{lang} in #{lang_dir}"
        lang.to_sym
      end
    end

    # List all sources available, builtin and custom
    # @return [Hash] A hash of source names and their corresponding RandomWords::Source objects
    def sources
      return @sources if @sources

      @sources = {}
      Dir[File.join(__dir__, "words", "*")].each do |dir|
        next unless File.directory?(dir)
        name = File.basename(dir)
        @sources[name] = RandomWords::Source.new(name, dir)
      end
      Dir[File.join(config_dir, "words", "*")].each do |dir|
        next unless File.directory?(dir)
        name = File.basename(dir)
        @sources[name] = RandomWords::Source.new(name, dir)
      end
      @sources
    end
  end
end
