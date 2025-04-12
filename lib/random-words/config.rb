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

    def initialize(lang)
      @lang = lang.to_s
      FileUtils.mkdir_p(config_dir) unless File.directory?(config_dir)

      @source_dir = user_dictionary_exist? ? user_lang_dir : builtin_lang_dir

      raise "No dictionary found for #{@lang}" unless @source_dir

      rw_source = RandomWords::Source.new(@lang, @source_dir)

      @dictionary = rw_source.dictionary

    end

    def config_dir
      @config_dir ||= File.expand_path(File.join(Dir.home, '.config', 'random-words'))
    end

    def user_dictionary_exist?
      if user_lang_dir
        raise "User dictionary for #{@lang} is incomplete. Please run create_user_dictionary." unless all_parts_of_speech?(user_lang_dir, @lang)

        true
      else
        false
      end
    end

    def user_lang_dir
      File.join(config_dir, 'words', @lang) if File.exist?(File.join(config_dir, 'words', @lang))
    end

    def builtin_lang_dir(lang = nil, basedir: nil)
      lang ||= @lang
      basedir ||= __dir__
      dir = File.join(basedir, 'words', lang)
      return dir if File.directory?(dir)

      warn "No dictionary found for #{lang}"
      nil
    end

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
      else
        warn "Failed to create dictionary for #{lang}"
        nil
      end
    end

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
