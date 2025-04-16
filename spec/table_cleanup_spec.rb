# frozen_string_literal: true

RSpec.describe RandomWords::TableCleanup do
  let(:content) { "| Header 1 | Header 2 |\n|:---|:---|\n| Content 1... | Content 2... |" }
  let(:cleaner) { described_class.new(content) }

  describe '#initialize' do
    it 'creates a new TableCleanup instance' do
      expect(cleaner).to be_a(described_class)
    end

    it 'accepts content and options' do
      options = { max_cell_width: 20, max_table_width: 40 }
      expect { described_class.new(content, options) }.not_to raise_error
    end
  end

  describe '#parse_cells' do
    it 'splits row string into cells' do
      row = '| cell 1... | cell 2... |'
      expect(cleaner.parse_cells(row)).to eq(['cell 1...', 'cell 2...'])
    end
  end

  describe '#align' do
    it 'aligns text left' do
      expect(cleaner.align(:left, 'text', 10)).to eq('text      ')
    end

    it 'aligns text right' do
      expect(cleaner.align(:right, 'text', 10)).to eq('      text')
    end

    it 'aligns text center' do
      expect(cleaner.align(:center, 'text', 10)).to eq('   text   ')
    end
  end

  describe '#clean' do
    it 'formats table content' do
      result = cleaner.clean
      expect(result).to include('| Header 1     | Header 2     |')
      expect(result).to include('|:-------------|:-------------|')
      expect(result).to include('| Content 1... | Content 2... |')
    end

    it 'handles table with alignment row' do
      content = "| Left | Center | Right |\n|:---|:---:|---:|\n| 1 | 2 | 3 |"
      cleaner = described_class.new(content)
      result = cleaner.clean
      expect(result).to include('| Left | Center | Right |')
      expect(result).to include('|:-----|--------|------:|')
    end
  end
end
