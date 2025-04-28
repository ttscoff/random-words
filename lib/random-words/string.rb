#!/usr/bin/env ruby
# frozen_string_literal: true

module RandomWords
  # String extensions for RandomWords
  # This module extends the String class with additional methods for cleaning,
  # compressing, and manipulating strings.
  #
  # @example
  #   str = "  Hello,  World!  "
  #   str.clean # => "Hello  World"
  #   str.compress # => "Hello, World!"
  #   str.terminate(["", "."]) # => "Hello World."
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

    # Capitalize instances of "i" in a string.
    # @return [String] The string with "i" capitalized.
    # @example
    #   "this is an i".capitalize_i # => "this is an I"
    # @example
    #   "this is an iPhone".capitalize_i # => "this is an iPhone"
    #
    def capitalize_i
      gsub(/\bi\b/, 'I')
    end

    # Capitalize the first letter of a string, respcting punctuation.
    # @return [String] The string with the first letter capitalized.
    # @example
    #  "hello world".capitalize # => "Hello world"
    def capitalize
      return self if empty?

      str = dup

      debug = ''
      str.sub!(/^%[A-Z]+%/) do |match|
        debug = match
        ''
      end

      letters = str.split('')
      string = []
      string << letters.shift while letters[0] !~ /[[:word:]]/
      string << letters.shift.upcase
      string.concat(letters)
      debug + string.join('')
    end

    # Downcase the first letter of a string, respecting punctuation.
    # @return [String] The string with the first letter downcased.
    def downcase_first
      return self if empty?

      letters = split('')
      string = []
      string << letters.shift while letters[0] !~ /[[:word:]]/
      string << letters.shift.downcase
      string.concat(letters)
      string.join('')
    end

    # Capitalize the first letter of each sentence in a string.
    # Scans for all known terminators followed by a space and capitalizes the next letter.
    # @param terminators [Array<Array>] An array of beginning and ending punctuation mark arrays.
    # @return [String] The string with the first letter of each sentence capitalized.
    # @example
    #   "hello world. this is a test.".fix_caps([[".", "."]]) # => "Hello world. This is a test."
    #
    def fix_caps(terminators)
      return self if empty?

      terminator_ends = terminators.map { |t| t[1].split('').last }.delete_if(&:empty?)
      return capitalize if terminator_ends.empty?

      terminator_regex = Regexp.new("[#{Regexp.escape(terminator_ends.join)}]")
      return capitalize unless match?(terminator_regex)

      split(/(?<=#{terminator_regex}) /).map do |sentence|
        sentence.capitalize
      end.join(' ')
    end

    # Remove duplicate punctuation
    # @return [String] The string with duplicate punctuation removed.
    # @example
    #  "Hello, , World!".dedup_punctuation # => "Hello, World!"
    def dedup_punctuation
      gsub(/((%[A-Z]+%)?[,.;:—] ?)+/, '\1').gsub(/([,;:—])/, '\1')
    end

    # Generate a sentence with capitalization and terminator
    # @param terminator [Array<String>] An array of beginning and ending punctuation marks.
    # @return [String] The string with a random punctuation mark at the end.
    def to_sent(terminator)
      capitalize.compress.capitalize_i.dedup_punctuation.terminate(terminator)
    end

    # Split a string by newlines, clean each line, and remove empty lines.
    # @return [Array<String>] The string split into lines, cleaned, and empty lines removed.
    # @example
    #   "Hello, World!\n\nThis is a test.".split_lines # => ["Hello World", "This is a test"]
    #
    def split_lines
      arr = strip.split("\n").map(&:clean)
      arr.reject!(&:empty?)
      arr
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
      debug = ''
      str = dup
      str.sub!(/^%[A-Z]+%/) do |match|
        debug = match
        ''
      end
      debug + str.sub(/^/, terminator[0]).sub(/[^a-zA-Z0-9]*$/, terminator[1])
    end

    # Remove any punctuation mark from the end of a string.
    # @return [String] The string with the last punctuation mark removed.
    def no_term(terminators)
      str = dup
      leading = terminators.map { |t| t[0] }.delete_if(&:empty?).sort.uniq.join
      trailing = terminators.map { |t| t[1] }.delete_if(&:empty?).sort.uniq.join
      return self if leading.empty? && trailing.empty?

      str.gsub!(/[#{Regexp.escape(leading)}]+/, '') unless leading.empty?

      str.gsub!(/[#{Regexp.escape(trailing)}]+/, '') unless trailing.empty?

      str
    end

    # Indent every line in a string with a specified string.
    # @param [String] string The string to indent with.
    # @return [String] The indented string.
    def indent(string)
      gsub(/^/, string)
    end

    # Capitalize the first letter of a string.
    # @return [String] The string with the first letter capitalized.
    def cap_first
      # Capitalizes the first letter of a string.
      self[0] = self[0].upcase
      self
    end

    # Add a specified character to the end of a string, avoiding repeated punctuation.
    # @param [String] char The character to add (default: '.').
    # @return [String] The string with the specified character at the end.
    def term(char = '.')
      # Adds a specified character to the end of a string.
      sub(/[.?!,;]?$/, "#{char}")
    end

    # Remove extra newlines from the output.
    # @return [String] The string with extra newlines removed.
    def compress_newlines
      # Removes extra newlines from the output.
      gsub(/\n{2,}/, "\n\n").strip
    end

    # Compress newlines in the output, destructive.
    # @see #compress_newlines
    # @return [String] The string with newlines compressed.
    def compress_newlines!
      # Removes extra newlines from the output.
      replace compress_newlines
    end

    # Preserve spaces in the output by replacing multiple spaces with %%.
    # @return [String] The string with spaces preserved.
    def preserve_spaces
      # Preserves spaces in the output.
      gsub(/ +/, '%%')
    end

    # Restore spaces in the output by replacing %% with spaces.
    # @return [String] The string with spaces restored.
    def restore_spaces
      # Restores spaces in the output.
      gsub('%%', ' ')
    end

    # Check if the string is trueish (starts with 't', 'y', or '1').
    # @return [Boolean] true if the string is trueish, false otherwise.
    def trueish?
      to_s =~ /^[ty1]/i
    end

    # Convert the string to a source symbol based on its name.
    # @return [Symbol] The symbolized name of the source.
    def to_source
      new_source = nil
      sources = RandomWords::Generator.new.sources

      sources.each do |_k, v|
        v.names.each do |name|
          next unless /^#{self}/i.match?(name.to_s)

          new_source = v.name
          break
        end
        break if new_source
      end

      new_source || :latin
    end

    # Convert the string to a length symbol based on its name.
    # @return [Symbol] The symbolized length of the string.
    def to_length
      case self
      when /^s/i
        :short
      when /^m/i
        :medium
      when /^l/i
        :long
      when /^v/i
        :very_long
      else
        :medium
      end
    end

    # Terminal output colors
    def colors
      {
        black: 30,
        red: 31,
        green: 32,
        yellow: 33,
        blue: 34,
        magenta: 35,
        cyan: 36,
        white: 37,
        boldblack: '1;30',
        boldred: '1;31',
        boldgreen: '1;32',
        boldyellow: '1;33',
        boldblue: '1;34',
        boldmagenta: '1;35',
        boldcyan: '1;36',
        boldwhite: '1;37',
        reset: 0
      }
    end

    # Colorize the text for terminal output.
    # @param text [String] The text to colorize.
    # @param color [Symbol] The color to use (e.g., :red, :green).
    #
    # If the output is not a TTY, the text is returned without colorization.
    #
    # @return [String] The colorized text.
    # @example
    #  colorize_text("Hello, World!", :red) # => "\e[31mHello, World!\e[0m"
    def colorize_text(text, color, testing: false)
      return text if !$stdout.isatty && !testing

      return text unless colors.key?(color)

      return text if text.empty?

      color_code = colors[color]

      "\e[#{color_code}m#{text}\e[0m"
    end

    # Dictionary of expansions
    def expansions
      {
        'ADJ' => ['Adjective', :yellow],
        'ADV' => ['Adverb', :boldyellow],
        'ART' => ['Article', :cyan],
        'CLA' => ['Clause', :magenta],
        'COC' => ['Coordinating Conjunction', :magenta],
        'CON' => ['Conjunction', :magenta],
        'NAM' => ['Name', :boldblue],
        'NOU' => ['Noun', :green],
        'NUM' => ['Number', :red],
        'PAV' => ['Passive Verb', :boldred],
        'PHR' => ['Phrase', :boldcyan],
        'PLA' => ['Plural Article', :yellow],
        'PLN' => ['Plural Noun', :green],
        'PLV' => ['Plural Verb', :boldred],
        'PNO' => ['Proper Noun', :boldblack],
        'PRE' => ['Preposition', :boldwhite],
        'PRP' => ['Prepositional Phrase', :boldwhite],
        'SEP' => ['Separator', :red],
        'SUC' => ['Subordinate Conjunction', :magenta],
        'TER' => ['Terminator', :boldcyan],
        'VER' => ['Verb', :boldred]
      }
    end

    # Expand abbreviated debug statements in the string.
    # @return [String] The expanded debug string.
    def expand_debug(testing: false)
      gsub(/%(#{Regexp.union(expansions.keys)})%?/) do
        match = Regexp.last_match

        return match unless expansions.key?(match[1])

        colorize_text("[#{expansions[match[1]][0] || match}]", expansions[match[1]][1] || :white, testing: testing)
      end
    end

    def article_agreement
      gsub(/\ban? (\w)/i) do |match|
        word = match[1]
        /\A[aeiou]/i.match?(word) ? "an #{word}" : "a #{word}"
      end
    end
  end
end
