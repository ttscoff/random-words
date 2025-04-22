# frozen_string_literal: true

RSpec.describe Integer do
  let(:english_numbers) do
    {
      digits: [nil, 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine'],
      teens: %w[ten eleven twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen],
      tens: %w[twenty thirty forty fifty sixty seventy eighty ninety],
      places: [nil, nil, 'hundred', 'thousand', 'million', 'billion', 'trillion']
    }
  end

  describe '#to_word' do
    it 'converts single digits' do
      expect(1.to_word(english_numbers)).to eq('one')
      expect(5.to_word(english_numbers)).to eq('five')
      expect(9.to_word(english_numbers)).to eq('nine')
    end

    it 'converts teens' do
      expect(10.to_word(english_numbers)).to eq('ten')
      expect(13.to_word(english_numbers)).to eq('thirteen')
      expect(19.to_word(english_numbers)).to eq('nineteen')
    end

    it 'converts tens' do
      expect(20.to_word(english_numbers)).to eq('twenty')
      expect(45.to_word(english_numbers)).to eq('forty five')
      expect(99.to_word(english_numbers)).to eq('ninety nine')
    end

    it 'converts hundreds' do
      expect(100.to_word(english_numbers)).to eq('one hundred')
      expect(242.to_word(english_numbers)).to eq('two hundred and forty two')
      expect(900.to_word(english_numbers)).to eq('nine hundred')
    end

    it 'converts thousands' do
      expect(1000.to_word(english_numbers)).to eq('one thousand')
      expect(4521.to_word(english_numbers)).to eq('four thousand five hundred and twenty one')
      expect(126_620.to_word(english_numbers)).to eq('one hundred and twenty six thousand six hundred and twenty')
    end

    it 'converts zero' do
      expect(0.to_word(english_numbers)).to eq('zero')
    end
  end

  describe '#additional_tests' do
    it 'tests edge cases' do
      expect(21.additional_tests(english_numbers)).to be true
      expect(9.additional_tests(english_numbers)).to be true
      expect(0.additional_tests(english_numbers)).to be true
    end
  end
end
