# frozen_string_literal: true

# require 'test_helper'

RSpec.describe RandomWords::HTML2Markdown do
  let(:html) { '<p>Hello world</p>' }
  let(:source) { File.read("spec/fixtures/sample.html") }
  let(:baseurl) { "http://example.com" }
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
      link = {href: 'http://example.com', title: 'Example'}
      expect(converter.add_link(link)).to eq(1)
    end

    it 'returns existing link index if duplicate' do
      link = {href: 'http://example.com', title: 'Example'}
      converter.add_link(link)
      expect(converter.add_link(link)).to eq(1)
    end
  end

  describe '#wrap' do
    it 'wraps text at 74 characters' do
      long_text = "A" * 100
      expect(converter.wrap(long_text)).to include("\n")
    end
  end
end