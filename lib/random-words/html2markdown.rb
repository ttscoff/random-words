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
    def initialize(str, baseurl = nil)
      @links = []
      @baseuri = (baseurl ? URI.parse(baseurl) : nil)
      @section_level = 0
      @encoding = str.encoding
      @markdown = output_for(Nokogiri::HTML(str, baseurl).root).gsub(/\n\n\n+/, "\n\n\n")
    end

    # Convert the HTML to Markdown
    # @return [String] The converted Markdown string
    # @example
    #   converter = HTML2Markdown.new('<p>Hello world</p>')
    #   puts converter.to_s
    def to_s
      i = 0
      @markdown = TableCleanup.new(@markdown).clean
      "#{@markdown}\n\n" + @links.map { |link|
        i += 1
        "[#{i}]: #{link[:href]}" + (link[:title] ? %( "#{link[:title]}") : '')
      }.join("\n")
    end

    # Recursively convert child nodes
    # @param node [Nokogiri::XML::Node] The parent node
    def output_for_children(node)
      node.children.map do |el|
        output_for(el)
      end.join
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
      return str if str =~ /\n/

      out = []
      line = []
      str.split(/[ \t]+/).each do |word|
        line << word
        if line.join(' ').length >= 74
          out << line.join(' ')
          line = []
        end
      end
      out << line.join(' ') + (str[-1..-1] =~ /[ \t\n]/ ? str[-1..-1] : '')
      out.join("\n")
    end

    # Convert a node to Markdown
    # @param node [Nokogiri::XML::Node] The node to convert
    # @return [String] The converted Markdown string
    def output_for(node)
      case node.name
      when 'head', 'style', 'script'
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
        "\n\n" + ('#' * (::Regexp.last_match(1).to_i + @section_level) + ' ' + output_for_children(node)) + "\n\n"
      when /mark/
        "==#{output_for_children(node)}=="
      when 'blockquote'
        @section_level += 1
        o = "\n\n> #{output_for_children(node).lstrip.gsub(/\n/, "\n> ")}\n\n".gsub(/> \n(> \n)+/, "> \n")
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
          "`#{output_for_children(node).gsub(/\n/, ' ')}`"
        end
      when 'pre'
        @in_pre = true
        lang = node['lang'] || node['language']
        lang = '' if lang.nil? || lang.empty?
        "\n\n```#{lang}\n" + output_for_children(node).lstrip + "\n```\n\n"
      when 'hr'
        "\n\n----\n\n"
      when 'a', 'link'
        link = { href: node['href'], title: node['title'] }
        "[#{output_for_children(node).gsub("\n", ' ')}][#{add_link(link)}]"
      when 'img'
        link = { href: node['src'], title: node['title'] }
        "![#{node['alt']}][#{add_link(link)}]"
      when 'video', 'audio', 'embed'
        link = { href: node['src'], title: node['title'] }
        "[#{output_for_children(node).gsub("\n", ' ')}][#{add_link(link)}]"
      when 'object'
        link = { href: node['data'], title: node['title'] }
        "[#{output_for_children(node).gsub("\n", ' ')}][#{add_link(link)}]"
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
          cells = node.children.select do |c|
            %w[th td].include?(c.name)
          end.count
          header = "\n|#{cells.times.map { '-------' }.join('|')}|\n"
        end
        node.children.select do |c|
          %w[th td].include?(c.name)
        end.map do |c|
          output_for(c)
        end.join.gsub(/\|\|/, '|') + header
      when 'th', 'td'
        "| #{output_for_children(node)} |"
      when 'text'
        # Sometimes Nokogiri lies. Force the encoding back to what we know it is
        if (c = node.content.force_encoding(@encoding)) =~ /\S/
          c.gsub!(/\n\n+/, '<$PreserveDouble$>')
          c.gsub!(/\s+/, ' ')
          c.gsub(/<\$PreserveDouble\$>/, "\n\n")
        else
          c
        end
      else
        output_for_children(node)
      end
    end
  end
end