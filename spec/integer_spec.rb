# frozen_string_literal: true

RSpec.describe Integer do
  let(:number_words) do
    {
      digits: {
        1 => 'one', 2 => 'two', 3 => 'three', 4 => 'four', 5 => 'five',
        6 => 'six', 7 => 'seven', 8 => 'eight', 9 => 'nine'
      },
      teens: %w[ten eleven twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen],
      tens: %w[twenty thirty forty fifty sixty seventy eighty ninety],
      places: ['', '', 'hundred', 'thousand', 'million', 'billion']
    }
  end

  describe '#to_word' do
    it 'converts single digits to words' do
      expect(0.to_word(number_words)).to eq('zero')
      expect(1.to_word(number_words)).to eq('one')
      expect(5.to_word(number_words)).to eq('five')
      expect(9.to_word(number_words)).to eq('nine')
    end

    it 'converts teens to words' do
      expect(10.to_word(number_words)).to eq('ten')
      expect(13.to_word(number_words)).to eq('thirteen')
      expect(19.to_word(number_words)).to eq('nineteen')
    end

    it 'converts tens to words' do
      expect(20.to_word(number_words)).to eq('twenty')
      expect(45.to_word(number_words)).to eq('forty five')
      expect(99.to_word(number_words)).to eq('ninety nine')
    end

    it 'converts hundreds to words' do
      expect(100.to_word(number_words)).to eq('one hundred')
      expect(101.to_word(number_words)).to eq('one hundred one')
      expect(999.to_word(number_words)).to eq('nine hundred ninety nine')
    end

    it 'converts thousands to words' do
      expect(1000.to_word(number_words)).to eq('one thousand')
      expect(1234.to_word(number_words)).to eq('one thousand two hundred thirty four')
      expect(999999.to_word(number_words)).to eq('nine hundred ninety nine thousand nine hundred ninety nine')
    end

    it 'converts zero to word' do
      expect(0.to_word(number_words)).to eq('zero')
    end
  end
end