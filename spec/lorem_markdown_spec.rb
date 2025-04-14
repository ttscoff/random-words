# frozen_string_literal: true

# require 'test_helper'

RSpec.describe RandomWords::LoremMarkdown do
  let(:options) { {} }
  let(:markdown) { described_class.new(options) }

  describe '#initialize' do
    it 'creates instance with default options' do
      expect(markdown.output).to be_a(String)
      expect(markdown.generator).to be_a(RandomWords::Generator)
    end

    context 'with custom options' do
      let(:options) do
        {
          source: :latin,
          grafs: 5,
          sentences: 3,
          length: :short,
          decorate: false,
          link: true,
          ul: true,
          ol: true,
          dl: true,
          bq: true,
          code: true,
          mark: true,
          headers: true,
          table: true
        }
      end

      it 'creates instance with custom options' do
        expect(markdown.output).to be_a(String)
        expect(markdown.generator).to be_a(RandomWords::Generator)
      end
    end
  end

  describe '#generate' do
    it 'generates markdown with lists when specified' do
      markdown = described_class.new(ul: true, ol: true)
      expect(markdown.output).to include('<ul>')
      expect(markdown.output).to include('<ol>')
    end

    it 'generates markdown with definition list when specified' do
      markdown = described_class.new(dl: true)
      expect(markdown.output).to include('<dl>')
    end

    it 'generates markdown with blockquote when specified' do
      markdown = described_class.new(bq: true)
      expect(markdown.output).to include('<blockquote>')
    end

    it 'generates markdown with headers when specified' do
      markdown = described_class.new(headers: true)
      expect(markdown.output).to include('<h1>')
    end

    it 'generates markdown with code blocks when specified' do
      markdown = described_class.new(code: true)
      expect(markdown.output).to include('<pre')
    end

    it 'generates markdown with tables when specified' do
      markdown = described_class.new(table: true)
      expect(markdown.output).to include('<table>')
    end
  end
end