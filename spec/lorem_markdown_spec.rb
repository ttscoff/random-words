# frozen_string_literal: true

# require 'test_helper'

RSpec.describe RandomWords::LoremMarkdown do
  let(:options) { {} }
  let(:markdown) { described_class.new(options) }

  context 'when generating headers' do
    context 'with different paragraph counts' do
      it 'generates 1 header for 1 paragraph' do
        markdown = RandomWords::LoremMarkdown.new(grafs: 1, headers: true)
        expect(markdown.output.scan(/<h\d>/).count).to eq(1)
      end

      it 'generates 2 headers for 2-3 paragraphs' do
        markdown = RandomWords::LoremMarkdown.new(grafs: 3, headers: true)
        expect(markdown.output.scan(/<h\d>/).count).to eq(2)
      end

      it 'generates 4 headers for 4-5 paragraphs' do
        markdown = RandomWords::LoremMarkdown.new(grafs: 5, headers: true)
        expect(markdown.output.scan(/<h\d>/).count).to eq(4)
      end

      it 'generates 5 headers for 6 paragraphs' do
        markdown = RandomWords::LoremMarkdown.new(grafs: 6, headers: true)
        expect(markdown.output.scan(/<h\d>/).count).to eq(5)
      end

      it 'generates 6 headers for 7+ paragraphs' do
        markdown = RandomWords::LoremMarkdown.new(grafs: 7, headers: true)
        expect(markdown.output.scan(/<h\d>/).count).to eq(6)
      end
    end

    it 'uses progressively deeper header levels' do
      markdown = RandomWords::LoremMarkdown.new(grafs: 10, headers: true)
      headers = markdown.output.scan(/<h(\d)>/).flatten.map(&:to_i)
      expect(headers).to eq(headers.sort)
    end
  end
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
    it 'adds unordered and ordered lists when both options are true' do
      markdown = described_class.new(ul: true, ol: true)
      expect(markdown.output).to include('<ul>')
      expect(markdown.output).to include('</ul>')
      expect(markdown.output).to include('<ol>')
      expect(markdown.output).to include('</ol>')
    end

    it 'adds only unordered list when ul option is true' do
      markdown = described_class.new(ul: true)
      expect(markdown.output).to include('<ul>')
      expect(markdown.output).to include('</ul>')
      expect(markdown.output).not_to include('<ol>')
    end

    it 'adds only ordered list when ol option is true' do
      markdown = described_class.new(ol: true)
      expect(markdown.output).to include('<ol>')
      expect(markdown.output).to include('</ol>')
      expect(markdown.output).not_to include('<ul>')
    end

    it 'adds definition list when dl option is true' do
      markdown = described_class.new(dl: true)
      expect(markdown.output).to include('<dl>')
      expect(markdown.output).to include('</dl>')
    end

    it 'adds blockquote when bq option is true' do
      markdown = described_class.new(bq: true)
      expect(markdown.output).to include('<blockquote>')
      expect(markdown.output).to include('</blockquote>')
    end

    it 'adds headers when headers option is true' do
      markdown = described_class.new(headers: true)
      expect(markdown.output).to include('<h1>')
      expect(markdown.output).to include('</h1>')
    end

    it 'adds code block when code option is true' do
      markdown = described_class.new(code: true)
      expect(markdown.output).to include('<pre')
      expect(markdown.output).to include('</pre>')
    end

    it 'adds table when table option is true' do
      markdown = described_class.new(table: true)
      expect(markdown.output).to include('<table>')
      expect(markdown.output).to include('</table>')
    end

    it 'generates markdown with definition list when specified' do
      markdown = described_class.new(dl: true)
      expect(markdown.output).to include('<dl>')
    end

    it 'generates markdown with blockquote when specified' do
      markdown = described_class.new(bq: true)
      expect(markdown.output).to include('<blockquote>')
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
