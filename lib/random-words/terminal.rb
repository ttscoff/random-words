module RandomWords
  # Terminal methods for testing
  class Terminal
    def initialize(source = :english)
      # Create an instance of the generator
      @sentence_generator = RandomWords::Generator.new(source)
      @sentence_generator.use_extended_punctuation = true
      @colors = {
        text: :yellow,
        counter: :boldcyan,
        marker: :boldgreen,
        bracket: :cyan,
        language: :boldmagenta
      }
      @sources = @sentence_generator.sources.keys.map(&:to_s)
    end

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

    def colorize_text(text, color)
      return text unless $stdout.isatty

      return text unless colors.key?(color)

      color_code = colors[color]

      "\e[#{color_code}m#{text}\e[0m"
    end

    def header_1(text)
      puts colorize_text("\n\n#{text}", :boldgreen)
      puts colorize_text('=' * text.length, :boldgreen)
      puts "\n"
    end

    def header_2(text)
      puts colorize_text("\n\n#{text}", :boldyellow)
      puts colorize_text('-' * text.length, :boldyellow)
      puts "\n"
    end

    def paragraphs(length, count = 3)
      @sentence_generator.sentence_length = length
      @sentence_generator.paragraph_length = count
      @sentence_generator.source = @sources.sample

      header_2("Random Paragraph (#{@sentence_generator.paragraph_length} #{@sentence_generator.sentence_length} sentences)")
      graf = @sentence_generator.paragraph
      puts text(graf)
      puts counter("#{graf.split(/ /).count} words, #{graf.length} characters")
    end

    def sentence(length)
      header_2("Random #{length} sentence")
      @sentence_generator.sentence_length = length
      s = @sentence_generator.sentence
      puts text(s)
      puts counter("#{s.split(/ /).count} words, #{s.length} characters")
    end

    # Generate and print random combined sentences
    def combined_sentences(length = nil)
      number_of_sentences = length || 2

      header_1('Random Combined Sentences:')
      @sources.count.times do |i|
        @sentence_generator.source = @sources[i - 1]
        @sentence_generator.sentence_length = :medium
        @sentence_generator.paragraph_length = number_of_sentences
        @sentence_generator.sentences(number_of_sentences)
        s = @sentence_generator.sentence
        puts "#{marker} #{text(s)}"
        puts counter("#{s.split(/ /).count} words, #{s.length} characters")
        puts colorize_text(' ' * 2, :boldwhite)
      end
    end

    def random_sentences
      header_1('Random Sentences')
      @sentence_generator.lengths.keys.each_with_index do |length, index|
        @sentence_generator.source = @sources[index]
        sentence(length)
      end
    end

    def random_paragraphs
      header_1('Random Paragraphs')
      @sentence_generator.lengths.keys.each_with_index do |length, index|
        @sentence_generator.source = @sources[index]
        paragraphs(length, 3)
      end
    end

    # Generate and print specified number of words
    def random_words
      number_of_words = []
      @sources.count.times do |i|
        number_of_words << (((i * i) * 5) + 10)
      end

      header_1("#{number_of_words} Random Words")
      @sources.each_with_index do |source, index|
        header_2("#{number_of_words[index]} Random Words")
        @sentence_generator.source = source
        s = @sentence_generator.words(number_of_words[index])
        puts "#{marker} #{text(s)}  "
        puts counter("#{s.split(/ /).count} words, #{s.length} characters")
      end
    end

    # Generate and print specified number of characters
    def random_characters
      header_1('Random Characters (exact length)')
      [20, 50, 120, 200, 500].each_with_index do |i, index|
        @sentence_generator.source = @sources[index]
        chars = @sentence_generator.characters(i, whole_words: true)
        puts "#{marker} #{colorize_text("#{i}:", :boldwhite)} #{text(chars)} #{counter(chars.length)}"
      end

      # Generate and print specified number of characters
      max_characters = [15, 25, 53, 110, 600]
      min_characters = [10, 20, 50, 100, 500]

      header_1('Random Characters (length range)')
      max_characters.count.times do |i|
        @sentence_generator.source = @sources[i]
        chars = @sentence_generator.characters(min_characters[i], max_characters[i], whole_words: true)
        range = "#{marker} #{colorize_text("[#{min_characters[i]}-#{max_characters[i]}]: ", :boldwhite)}"
        puts "#{range}#{text(chars)} #{counter(chars.length)}"
      end
    end

    def marker
      colorize_text('•', @colors[:marker])
    end

    def text(text)
      colorize_text(text, @colors[:text])
    end

    def language
      "#{colorize_text('(',
                       @colors[:bracket])}#{colorize_text("#{@sentence_generator.source}",
                                                          @colors[:language])}#{colorize_text(')',
                                                                                              @colors[:bracket])}"
    end

    def counter(length)
      "#{colorize_text('[',
                       @colors[:bracket])}#{colorize_text("#{length}",
                                                          @colors[:counter])}#{colorize_text(']',
                                                                                             @colors[:bracket])} #{language}"
    end

    def print_test
      combined_sentences(3)
      random_sentences
      random_paragraphs
      random_words
      random_characters
    end
  end
end
