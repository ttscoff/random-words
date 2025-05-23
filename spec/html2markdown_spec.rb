# frozen_string_literal: true

# require 'test_helper'

RSpec.describe RandomWords::HTML2Markdown do
  let(:html) { '<p>Hello world</p>' }
  let(:source) { File.read('spec/fixtures/sample.html') }
  let(:baseurl) { 'http://example.com' }
  let(:converter) { described_class.new(html, baseurl) }

  describe '#initialize' do
    it 'creates a new HTML2Markdown converter' do
      expect(converter).to be_a(described_class)
    end

    it 'accepts HTML string and base URL' do
      expect { described_class.new(html, baseurl) }.not_to raise_error
    end

    it 'parses HTML and converts to Markdown' do
      html_test = described_class.new(source, baseurl)
      expect(html_test.markdown).to match(/# Quisque/)
    end

    it 'handles input with metadata' do
      meta = { title: 'Test Title', date: '2024-01-01', type: :yaml }
      converter = described_class.new('<p>Test content</p>', nil, meta)
      output = converter.to_s

      expect(output).to include('---')
      expect(output).to include('title: Test Title')
      expect(output).to include('date: 2024-01-01')
      expect(output).to match(/Test content/)
    end

    it 'converts footnotes correctly' do
      html = '<p>Text<a href="#fn:1" title="Footnote 1">1</a> and <a href="#fn:2" title="Footnote 2">2</a></p>'
      converter = described_class.new(html)
      output = converter.to_s

      expect(output).to include('[^fn1]')
      expect(output).to include('[^fn2]')
      expect(output).to include('[^fn1]: Footnote 1')
      expect(output).to include('[^fn2]: Footnote 2')
    end

    it 'handles different input types' do
      string_io = StringIO.new('<p>Test</p>')
      def string_io.output
        string
      end

      converter = described_class.new(string_io)
      expect(converter.to_s.strip).to eq('Test')
    end

    it 'preserves encoding of input text' do
      utf8_text = '<p>こんにちは</p>'.encode('UTF-8')
      converter = described_class.new(utf8_text)
      expect(converter.to_s.encoding).to eq(Encoding::UTF_8)
    end

    it 'handles complete html with title tag' do
      complete_html = <<~HTML
        <!DOCTYPE html>
        <html>
          <head>
            <title>Test Title</title>
          </head>
          <body>
            <p>Hello world</p>
          </body>
        </html>
      HTML

      converter = described_class.new(complete_html, 'https://example.com', { type: :yaml })
      expect(converter.to_s).to include('Test Title')
      expect(converter.to_s).to include('Hello world')

      converter = described_class.new(complete_html, 'https://example.com', { type: :multimarkdown })
      expect(converter.to_s).to include('title: Test Title')
    end
  end

  describe '#to_s' do
    it 'converts simple paragraph' do
      expect(converter.to_s.strip).to eq('Hello world')
    end

    it 'converts headings' do
      converter = described_class.new('<h1>Title</h1>')
      expect(converter.to_s.strip).to eq('# Title')
    end

    it 'converts links' do
      converter = described_class.new('<a href="http://example.com">Link</a>')
      expect(converter.to_s).to include('[Link][1]')
      expect(converter.to_s).to include('[1]: http://example.com')
    end

    it 'converts bold text' do
      converter = described_class.new('<strong>Bold</strong>')
      expect(converter.to_s.strip).to eq('**Bold**')
    end

    it 'converts italic text' do
      converter = described_class.new('<em>Italic</em>')
      expect(converter.to_s.strip).to eq('_Italic_')
    end

    it 'converts lists' do
      converter = described_class.new('<ul><li>Item 1</li><li>Item 2</li></ul>')
      expect(converter.to_s).to include('* Item 1')
      expect(converter.to_s).to include('* Item 2')
    end

    it 'converts code blocks' do
      converter = described_class.new('<pre><code>Code block</code></pre>')
      expect(converter.to_s).to include('```')
      expect(converter.to_s).to include('Code block')
    end
  end

  describe '#add_link' do
    it 'adds link to collection' do
      link = { href: 'http://example.com', title: 'Example' }
      expect(converter.add_link(link)).to eq(1)
    end

    it 'returns existing link index if duplicate' do
      link = { href: 'http://example.com', title: 'Example' }
      converter.add_link(link)
      expect(converter.add_link(link)).to eq(1)
    end
  end

  describe '#wrap' do
    it 'wraps text at 74 characters' do
      long_text = 'A' * 100
      expect(converter.wrap(long_text)).to include("\n")
    end
  end
end
