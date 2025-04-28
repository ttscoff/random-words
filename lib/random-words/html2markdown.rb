# frozen_string_literal: true

require 'uri'
require 'nokogiri'
require_relative 'table-cleanup'

module RandomWords
  # Convert HTML to Markdown
  class HTML2Markdown
    attr_reader :markdown

    # Initialize the HTML2Markdown converter
    # @param str [String] The HTML string to convert
    # @param baseurl [String] The base URL for resolving relative links
    def initialize(str, baseurl = nil, meta = {})
      @links = []
      @footnotes = []
      @baseuri = (baseurl ? URI.parse(baseurl) : nil)
      @section_level = 0
      input = str.is_a?(String) ? str : str.output
      @encoding = input.encoding
      @markdown = output_for(Nokogiri::HTML(input, baseurl).root).gsub(/\n\n\n+/, "\n\n\n").strip
      @title = meta[:title] if meta[:title]
      @date = meta[:date] if meta[:date]
      @style = meta[:style] if meta[:style]
      @meta_type = meta[:type] if meta[:type]
    end

    # Convert the HTML to Markdown
    # @return [String] The converted Markdown string
    # @example
    #   converter = HTML2Markdown.new('<p>Hello world</p>')
    #   puts converter.to_s
    def to_s
      meta = ''

      if @meta_type
        meta = <<~EOMETA
          title: #{@title}
          date: #{@date}
          css: #{@style}
        EOMETA
        case @meta_type
        when :multimarkdown
          meta = <<~EOMMD
            #{meta.strip}

          EOMMD
        when :yaml
          meta = <<~EOYAML
            ---
            #{meta.strip}
            ---
          EOYAML
        end
      end
      i = 0
      @markdown = TableCleanup.new(@markdown).clean
      out = "#{meta}#{@markdown}"

      if @links.any?
        out += "\n\n" + @links.map do |link|
          i += 1
          "[#{i}]: #{link[:href]}" + (link[:title] ? %( "#{link[:title]}") : '')
        end.join("\n")
      end

      if @footnotes.any?
        out += "\n\n" + @footnotes.map { |link|
          "[^fn#{link[:counter]}]: #{link[:title]}"
        }.join("\n\n")
      end
      out
    end

    # Recursively convert child nodes
    # @param node [Nokogiri::XML::Node] The parent node
    def output_for_children(node)
      node.children.map do |el|
        output_for(el)
      end.join
    end

    # Add a footnote to the list of links
    # @param counter [String] The footnote counter
    # @param link [Hash] The link to add
    def add_footnote(counter, link)
      @footnotes << { counter: counter, title: link[:title] }
      @footnotes.length
    end

    # Add a link to the list of links
    # @param link [Hash] The link to add
    def add_link(link)
      if @baseuri
        begin
          link[:href] = URI.parse(link[:href])
        rescue Exception
          link[:href] = URI.parse('')
        end
        link[:href].scheme = @baseuri.scheme unless link[:href].scheme
        unless link[:href].opaque
          link[:href].host = @baseuri.host unless link[:href].host
          link[:href].path = @baseuri.path.to_s + '/' + link[:href].path.to_s if link[:href].path.to_s[0] != '/'
        end
        link[:href] = link[:href].to_s
      end
      @links.each_with_index do |l, i|
        return i + 1 if l[:href] == link[:href]
      end
      @links << link
      @links.length
    end

    # Wrap a string to 74 characters
    # @param str [String] The string to wrap
    # @return [String] The wrapped string
    def wrap(str)
      return str if str.include?("\n")

      out = []
      line = []
      str.split(/[ \t]+/).each do |word|
        line << word
        if line.join(' ').length >= 74
          out << line.join(' ')
          line = []
        end
      end
      out << (line.join(' ') + (/[ \t\n]/.match?(str[-1..-1]) ? str[-1..-1] : ''))
      out.join("\n")
    end

    # Convert a node to Markdown
    # @param node [Nokogiri::XML::Node] The node to convert
    # @return [String] The converted Markdown string
    def output_for(node)
      case node.name
      when 'title'
        @title = node.content
        ''
      when 'head'
        output_for_children(node)
        ''
      when 'style', 'script'
        ''
      when 'br'
        "  \n"
      when 'p', 'div'
        "\n\n#{output_for_children(node)}\n\n"
      when 'section', 'article'
        @section_level += 1
        o = "\n\n----\n\n#{output_for_children(node)}\n\n"
        @section_level -= 1
        o
      when /h(\d+)/
        "\n\n" + (('#' * (::Regexp.last_match(1).to_i + @section_level)) + ' ' + output_for_children(node)) + "\n\n"
      when /mark/
        "==#{output_for_children(node)}=="
      when 'blockquote'
        @section_level += 1
        o = "\n\n> #{output_for_children(node).lstrip.gsub("\n", "\n> ")}\n\n".gsub(/> \n(> \n)+/, "> \n").sub(/> \n$/,
                                                                                                               "\n")
        @section_level -= 1
        o
      when 'cite'
        "*#{output_for_children(node)}*"
      when 'ul'
        "\n\n" + node.children.map { |el|
          next if el.name == 'text'

          "* #{output_for_children(el).gsub(/^(\t)|(    )/, "\t\t").gsub(/^>/, "\t>")}\n"
        }.join + "\n\n"
      when 'ol'
        i = 0
        "\n\n" + node.children.map { |el|
          next if el.name == 'text'

          i += 1
          "#{i}. #{output_for_children(el).gsub(/^(\t)|(    )/, "\t\t").gsub(/^>/, "\t>")}\n"
        }.join + "\n\n"
      when 'code'
        if @in_pre
          @in_pre = false
          node.text.strip
        else
          "`#{output_for_children(node).tr("\n", ' ')}`"
        end
      when 'pre'
        @in_pre = true
        lang = node['lang'] || node['language']
        lang = '' if lang.nil? || lang.empty?
        "\n\n```#{lang}\n" + output_for_children(node).lstrip + "\n```\n\n"
      when 'hr'
        "\n\n* * * *\n\n"
      when 'a', 'link'
        link = { href: node['href'], title: node['title'] }
        if link[:href] =~ /^#fn:(\d+)/
          counter = Regexp.last_match[1]
          add_footnote(counter, link)
          "[^fn#{counter}]"
        else
          "[#{output_for_children(node).tr("\n", ' ')}][#{add_link(link)}]"
        end
      when 'img'
        link = { href: node['src'], title: node['title'] }
        "![#{node['alt']}][#{add_link(link)}]"
      when 'video', 'audio', 'embed'
        link = { href: node['src'], title: node['title'] }
        "[#{output_for_children(node).tr("\n", ' ')}][#{add_link(link)}]"
      when 'object'
        link = { href: node['data'], title: node['title'] }
        "[#{output_for_children(node).tr("\n", ' ')}][#{add_link(link)}]"
      when 'i', 'em', 'u'
        "_#{output_for_children(node)}_"
      when 'b', 'strong'
        "**#{output_for_children(node)}**"
      when 'dl'
        "\n\n" + node.children.map do |el|
          case el.name
          when 'dt'
            "#{output_for_children(el)}\n"
          when 'dd'
            ": #{output_for_children(el)}\n\n"
          end
        end.join + "\n\n"
      # Tables are not part of Markdown, so we output WikiCreole
      when 'table'
        @table_header = true
        node.children.select do |c|
          %w[tr tbody thead].include?(c.name)
        end.map do |c|
          output_for(c)
        end.join
      when 'tr'
        header = "\n"
        if @table_header
          @table_header = false
          cells = node.children.count do |c|
            %w[th td].include?(c.name)
          end
          header = "\n|#{Array.new(cells) { '-------' }.join('|')}|\n"
        end
        node.children.select do |c|
          %w[th td].include?(c.name)
        end.map do |c|
          output_for(c)
        end.join.gsub('||', '|') + header
      when 'th', 'td'
        "| #{output_for_children(node)} |"
      when 'text'
        # Sometimes Nokogiri lies. Force the encoding back to what we know it is
        if /\S/.match?((c = node.content.force_encoding(@encoding)))
          c.gsub!(/\n\n+/, '<$PreserveDouble$>')
          c.gsub!(/\s+/, ' ')
          c.gsub('<$PreserveDouble$>', "\n\n")
        else
          c
        end
      else
        output_for_children(node)
      end
    end
  end
end
