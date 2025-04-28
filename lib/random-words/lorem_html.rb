# frozen_string_literal: true

module RandomWords
  # Generates random Lorem Ipsum text in Markdown format.
  class LoremHTML
    # Stores the output
    attr_accessor :output

    # Stores the RandomWords::Generator
    attr_accessor :generator

    # Stores the title
    attr_reader :title

    # Generates random Lorem Ipsum text.
    # @param options [Hash] Options for generating Lorem Ipsum text.
    #
    # @option options [Symbol] :source The source of the words (:latin, :english, :french, etc.).
    # @option options [Integer] :grafs The number of paragraphs to generate.
    # @option options [Integer] :sentences The number of sentences per paragraph.
    # @option options [Symbol] :length The length of the text (:short, :medium, :long, :very_long).
    # @option options [Boolean] :decorate Whether to include emphasis and strong tags.
    # @option options [Boolean] :link Whether to include links.
    # @option options [Boolean] :ul Whether to include unordered lists.
    # @option options [Boolean] :ol Whether to include ordered lists.
    # @option options [Boolean] :dl Whether to include definition lists.
    # @option options [Boolean] :bq Whether to include blockquotes.
    # @option options [Boolean] :code Whether to include code blocks.
    # @option options [Boolean] :mark Whether to include mark tags.
    # @option options [Boolean] :headers Whether to include headers.
    # @option options [Boolean] :table Whether to include tables.
    # @option options [Boolean] :extended Whether to use extended punctuation.
    # @return [String] A string of random Lorem Ipsum text.
    def initialize(options = {})
      @added = {
        italic: false,
        strong: false,
        link: false,
        code: false,
        mark: false,
        footnote: false,
        hr: false
      }

      defaults = {
        source: :latin,
        grafs: 10,
        sentences: 5,
        length: :medium,
        decorate: true,
        link: false,
        ul: false,
        ol: false,
        dl: false,
        bq: false,
        code: false,
        mark: false,
        headers: false,
        table: false,
        extended: false,
        footnote: false,
        hr: false,
        image: false
      }

      @options = defaults.merge(options)

      @generator = RandomWords::Generator.new(@options[:source], {
                                                sentence_length: @options[:length],
                                                paragraph_length: @options[:sentences],
                                                use_extended_punctuation: @options[:extended]
                                              })
      @title = fragment(2, 5).cap_first

      @output = ''
      strong = @options[:decorate]
      italic = @options[:decorate]
      links = @options[:link]
      code = @options[:code]
      mark = @options[:mark]
      footnotes = @options[:footnote]
      @options[:hr]
      @options[:image]
      force = []
      # Generate the specified number of paragraphs.
      @options[:grafs].times.with_index do |_, i|
        if @options[:grafs] == 1 || i == @options[:grafs] - 2
          force << :footnote if !@added[:footnote] && @options[:footnote]
          force << :code if !@added[:code] && @options[:code]
          force << :link if !@added[:link] && @options[:link]
          force << :italic if !@added[:italic] && @options[:decorate]
          force << :strong if !@added[:strong] && @options[:decorate]
        end

        @output += paragraph(1, italic: italic, strong: strong, links: links, code: code, mark: mark, footnotes: footnotes,
                                force: force)
        italic = Random.rand(0..3).zero? && @options[:decorate]
        strong = Random.rand(0..3).zero? && @options[:decorate]
        links = Random.rand(0..3).zero? && @options[:link]
        code = Random.rand(0..3).zero? && @options[:code]
        footnotes = Random.rand(0..3).zero? && @options[:footnote]

        @output += "\n\n"
      end

      generate
    end

    # Use the RandomWords class to generate the Lorem Ipsum text.
    #
    # @return [String] The generated Lorem Ipsum HTML.
    def generate
      compress_newlines
      handle_lists
      handle_basic_elements
      handle_content_blocks
      finalize_output
      @output
    end

    private

    def handle_lists
      items = { short: 4, medium: 8, long: 10, very_long: 12 }[@options[:length]]

      if @options[:ul] && @options[:ol]
        inject_block(1, -> { list(items, :ul) })
        inject_block(1, -> { list(items, :ol) })
      elsif @options[:ul]
        inject_block(2, -> { list(items, :ul) })
      elsif @options[:ol]
        inject_block(2, -> { list(items, :ol) })
      end
    end

    def handle_basic_elements
      inject_block(1, -> { "<hr>\n\n" }) if @options[:hr]

      return unless @options[:image]

      inject_block(1, lambda {
        "<img src=\"https://picsum.photos/400/200\" alt=\"#{fragment(1, 4).cap_first}\" />\n\n"
      })
    end

    def handle_content_blocks
      items = { short: 4, medium: 8, long: 10, very_long: 12 }[@options[:length]]

      inject_block(1, -> { list(items, :dl) }) if @options[:dl]
      inject_block(1, -> { blockquote(items / 2) }) if @options[:bq]
      inject_headers if @options[:headers]
      inject_block(1, -> { code }) if @options[:code]
      inject_block(1, -> { table }) if @options[:table]
    end

    def finalize_output
      ensure_block_newlines
      compress_newlines
      convert_punctuation
    end

    # Convert non-ascii punctuation to Markdown equivalents.
    # @param [String] text The text to convert.
    #
    # @return [String] The converted text.
    def convert_punctuation
      text = @output
      text.gsub!(/“|”/, '"')
      text.gsub!(/‘|’/, "'")
      text.gsub!(/–/, '-')
      text.gsub!(/—/, '--')
      text.gsub!(/—/, '---')
      text.gsub!(/•/, '*')
      text.gsub!(/…/, '...')
      @output = text
    end

    # Roll a random number to determine if an action should occur
    # @param percent [Integer] 1-100 percent chance of the action occurring (1-100)
    #
    # @return [Boolean] True if the action occurs, false otherwise
    #
    # @example
    #   roll(50) # 50% chance of returning true
    def roll(percent)
      rand(1..100) <= percent
    end

    # Generates a list of items.
    # @param [Integer] count The number of items to generate.
    # @param [Symbol] type The type of list to generate (:ul, :ol, :dl).
    #
    # @return [String] The generated list.
    def list(count, type)
      ul = "\n\n<#{type}>\n"

      count.times do
        links = roll(20) && @options[:link]
        italic = roll(50) && @options[:decorate]
        strong = roll(50) && @options[:decorate]
        code = roll(10) && @options[:code]
        mark = roll(10) && @options[:mark]

        frag = fragment(1, 4).cap_first
        long_frag = fragment(4, 8).cap_first
        long_frag = inject_inline(long_frag, -> { link }) if links
        long_frag = inject_inline(long_frag, -> { emphasis(:em) }) if italic
        long_frag = inject_inline(long_frag, -> { emphasis(:strong) }) if strong
        long_frag = inject_inline(long_frag, -> { code_span }, 1) if code
        long_frag = inject_inline(long_frag, -> { emphasis(:mark) }, 1) if mark

        long_frag = long_frag.restore_spaces if links
        if type == :dl
          ul += "\t<dt>#{frag}</dt>\n"
          ul += "\t<dd>#{long_frag}</dd>\n"
        else
          ul += "\t<li>#{long_frag}</li>\n"
        end
      end
      ul + "</#{type}>\n\n"
    end

    # Generates a blockquote.
    # @param [Integer] count The number of items to generate.
    # @param [Boolean] nested Whether the blockquote is nested.
    #
    # @return [String] The generated blockquote.
    def blockquote(count, nested: false)
      if count > 1 && !nested
        level1 = Random.rand(1..count - 1).to_i
        level2 = count - level1
      else
        level1 = 1
        level2 = 0
      end
      cite = "\n<cite>— #{@generator.name}</cite>\n" unless nested
      newline = nested ? '' : "\n\n"
      quote = "#{newline}<blockquote>\n"
      quote += paragraph(level1,
                         italic: @options[:decorate],
                         strong: @options[:decorate],
                         links: @options[:link],
                         code: @options[:code],
                         mark: @options[:mark]).squeeze("\n")
      quote += blockquote(level2, nested: true).strip if level2.positive?
      "#{quote}#{cite}</blockquote>#{newline}"
    end

    # Generates a header.
    # @param [Integer] level The level of the header (1-6).
    # @return [String] The generated header.
    def header(level)
      level = 6 if level > 6
      pre = level > 1 ? "\n\n" : ''
      h = "#{pre}<h#{level}>"
      h += fragment(2, 8).cap_first
      h + "</h#{level}>\n\n"
    end

    # Injects headers in the output. Number injected depends on overall length
    # of the input.
    # @return [String] The output with injected headers.
    def inject_headers
      count = if @options[:grafs] == 1
                1
              elsif @options[:grafs] <= 3
                2
              elsif @options[:grafs] <= 5
                4
              elsif @options[:grafs] == 6
                5
              else
                6
              end
      grafs = @output.split("\n\n").reverse

      @output = header(1)
      @output += "#{grafs.slice!(-1)}\n\n"

      if count == 1
        grafs = grafs.reverse
        @output += grafs.join("\n\n")
        return
      end

      level = 2

      c = (grafs.length / count).to_i

      while grafs.any? && level <= count
        @output += header(level)
        @output += grafs.slice!(grafs.length - c, c).join("\n\n")
        level += 1
      end
      @output += grafs.join("\n\n")
      compress_newlines
    end

    # Generates a random table. Length is determined by @options[:length]
    # @return [String] The generated table.
    def table
      items = { short: 2, medium: 2, long: 4, very_long: 6 }[@options[:length]]
      # Generates a random table.
      table = "\n\n<table>\n"
      table += "\t<tr>\n"
      items.times do
        table += "\t\t<th>#{fragment(1, 2).cap_first}</th>\n"
      end
      table += "\t</tr>\n"
      items.times do
        table += "\t<tr>\n"
        items.times do
          table += "\t\t<td>#{Random.rand(10_000)}</td>\n"
        end
        table += "\t</tr>\n"
      end
      table += "</table>\n\n"
      table
    end

    # Generates a random code block
    # @return [String] The generated code block.
    def code
      lang = @generator.code_lang
      code = "\n\n<pre lang=\"#{lang}\"><code>\n"
      code += "#{@generator.code_snippet(lang)}\n"
      "#{code}</code></pre>\n\n"
    end

    # Generates a random code span
    def code_span
      @added[:code] = true
      code = '<code>'
      code += "#{@generator.words(Random.rand(1..5))} "
      "#{code.strip}</code>"
    end

    # Generates a random emphasis tag
    # @param [String] tag The tag to use for emphasis.
    def emphasis(tag)
      @added[tag] = true
      "<#{tag}>#{fragment(1, 4)}</#{tag}>"
    end

    # Generates a random link
    # @return [String] The generated link.
    def link
      @added[:link] = true
      path = "/#{path_string(4, 8)}/#{path_string(4, 8)}"
      title = fragment(4, 8).cap_first
      "<a%%href=\"https://example.com#{path}\"%%title=\"#{title.preserve_spaces}\">#{fragment(1,
                                                                                              8)}</a>"
    end

    # Generates a random footnote
    # @return [String] The generated footnote.
    def footnote
      @added[:footnote] = true
      @counter ||= 0
      @counter += 1
      %(<a%%href="#fn:#{@counter}"%%id="fnref:#{@counter}"%%title="#{fragment(10,
                                                                              20)}"%%class="footnote"><sup>#{@counter}</sup></a>)
    end

    # Injects a block of text into the output.
    # @param [Integer] count The number of blocks to inject.
    # @param [Proc] block The block whose result to inject.
    def inject_block(count, block)
      grafs = @output.split("\n\n")

      len = if grafs.length < 2
              1
            else
              Random.rand(1..grafs.length / 2).to_i
            end

      @output = "#{grafs.slice!(0, len).join("\n\n")}\n\n"

      # count = { short: 4, medium: 8, long: 10, very_long: 12 }[@options[:length]]
      @output += block.call
      added = 1
      while grafs.any?
        len = Random.rand(1..grafs.length)

        @output += "#{grafs.slice!(0, len).join("\n\n")}\n\n"
        if added < count
          @output += block.call
          added += 1
        end
      end

      compress_newlines
    end

    # Injects inline text into the output.
    # @param [String] text The text to inject into.
    # @param [Proc] block The block whose result to inject.
    # @param [Integer] max The maximum number of times to inject the block.
    def inject_inline(text, block, max = nil)
      max ||= { short: 1, medium: 2, long: 3, very_long: 4 }[@options[:length]]

      words = text.split
      out = []
      count = 0
      while words.any?
        if count >= max
          out << words.slice!(0..-1)
          break
        else
          el = block.call
          out << words.slice!(0..Random.rand(1..words.length))
          out << el if words.any?
          count += 1
        end
      end
      out.join(' ').term
    end

    # Generates a paragraph of Lorem Ipsum text.
    # The `words` method generates a specified number of words.
    # @param [Integer] count The number of paragraphs to generate.
    # @param [Boolean] italic Whether to include italic tags.
    # @param [Boolean] strong Whether to include strong tags.
    # @param [Boolean] links Whether to include links.
    # @param [Boolean] code Whether to include code tags.
    # @param [Boolean] mark Whether to include mark tags.
    # @param [Array] force An array of tags to force.
    # @return [String] The generated paragraph.
    def paragraph(count, italic: false, strong: false, links: false, code: false, mark: false, footnotes: false, force: [])
      output = ''

      s = { short: 2, medium: 4, long: 6, very_long: 8 }[@options[:length]]
      count.times do
        p = @generator.sentences(s).join(' ')
        should_em = force.include?(:italic) || (italic && roll(60))
        should_strong = force.include?(:strong) || (strong && roll(60))
        should_code = force.include?(:code) || (code && roll(40))
        should_link = force.include?(:link) || (links && roll(40))
        should_mark = force.include?(:mark) || (mark && roll(40))
        should_footnote = force.include?(:footnote) || (footnotes && roll(40))

        p = inject_inline(p, -> { link }) if should_link
        p = inject_inline(p, -> { emphasis(:em) }) if should_em
        p = inject_inline(p, -> { emphasis(:strong) }) if should_strong
        p = inject_inline(p, -> { emphasis(:mark) }, 1) if should_mark
        p = inject_inline(p, -> { code_span }, 1) if should_code
        fn = should_footnote ? footnote.restore_spaces : ''
        output += "<p>#{p.restore_spaces.cap_first.term('.')}#{fn}</p>\n\n"
      end
      output
    end

    # Find block level tags and add newlines around them.
    def ensure_block_newlines
      # Adds newlines around block level tags.
      @output.gsub!(/(<(h\d|div|blockquote|dl|ul|ol)>)/, "\n\n\\1")
      @output.gsub!(%r{(</(h\d|div|blockquote|dl|ul|ol)>)\s*}, "\\1\n\n")
    end

    # Compresses newlines in the output.
    # This method removes extra newlines from the output.
    def compress_newlines
      @output.compress_newlines!
    end

    # Generates a random fragment of text.
    # The `words` method generates a specified number of words.
    # @param [Integer] min The minimum number of words to generate.
    # @param [Integer] max The maximum number of words to generate.
    # @return [String] The generated fragment.
    def fragment(min, max)
      @generator.words(Random.rand(min..max)).no_term(generator.terminators).downcase_first
    end

    # Generates a random string of characters.
    # The `characters` method generates a specified number of characters.
    def path_string(min, max)
      @generator.characters(min, max, whole_words: false, whitespace: false).downcase
    end
  end
end
