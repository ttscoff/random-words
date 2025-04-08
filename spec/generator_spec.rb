# frozen_string_literal: true

RSpec.describe RandomWords::Generator do
  subject(:generator) { described_class.new }

  describe '#initialize' do
    it 'creates a new generator with default values' do
      expect(generator.source).to eq(:english)
      expect(generator.lengths).to include(
        short: 60,
        medium: 200,
        long: 300,
        very_long: 500
      )
    end
  end

  describe '#bad_init' do
    it 'returns empty array when bad filename is provided' do
      expect(generator.bad_init).to be_empty
    end
  end

  describe '#word' do
    it 'returns a random word as string' do
      expect(generator.word).to be_a(String)
      expect(generator.word).not_to be_empty
    end
  end

  describe '#words' do
    it 'returns specified number of words' do
      [1, 5, 10].each do |count|
        result = generator.words(count)
        expect(result.split(' ').length).to eq(count)
        expect(result).to be_a(String)
        expect(result).not_to be_empty
      end
    end
  end

  describe '#characters' do
    it 'generates text of exact length' do
      [10, 50, 100].each do |length|
        result = generator.characters(length)
        expect(result.length).to eq(length)
      end
    end

    it 'respects min and max parameters' do
      result = generator.characters(10, 20)
      expect(result.length).to be_between(10, 20)
    end

    it 'truncates text if it exceeds max length' do
      result = generator.characters(100, 1, whole_words: false)
      expect(result.length).to eq(1)
    end

    it 'returns a single character word' do
      expect(generator.characters(100, 1, whole_words: true)).to match(/\A\w\z/)
    end

    it 'returns 2 characters' do
      expect(generator.characters(100, 2, whole_words: true)).to match(/\A\w+\z/)
    end
  end

  describe 'randomness' do
    it 'generates random words' do
      expect(generator.test_random).to all(be_a(String))
    end
  end

  describe '#lengths' do
    it 'returns the lengths hash' do
      expect(generator.lengths).to be_a(Hash)
      expect(generator.lengths).to include(
        short: 60,
        medium: 200,
        long: 300,
        very_long: 500
      )
    end

    it 'raises an error if length symbol is unrecognized' do
      expect { generator.bad_length }.to raise_error(ArgumentError)
    end

    it 'defines all lengths' do
      expect(generator.define_all_lengths).to eq([60, 200, 300, 500])
    end
  end

  describe '#sentence' do
    it 'generates a valid sentence' do
      result = generator.sentence
      expect(result).to match(/^[A-Z].*[.!?]$/)
    end
  end

  describe '#sentences' do
    it 'generates multiple sentences' do
      result = generator.sentences(3)
      expect(result).to be_an(Array)
      expect(result.length).to eq(3)
      expect(result).to all(match(/^[A-Z].*[.!?]$/))
    end
  end

  describe '#paragraph' do
    it 'generates multiple sentences' do
      result = generator.paragraph(3)
      expect(result).to be_a(String)
      expect(result).not_to be_empty
      expect(result.scan(/[.!?]/).count).to eq(3)
    end
  end

  describe '#lengths=' do
    it 'updates length settings' do
      generator.lengths = { short: 30 }
      expect(generator.lengths[:short]).to eq(30)
    end
  end

  describe '#source=' do
    it 'updates the source' do
      generator.source = :corporate
      expect(generator.source).to eq(:corporate)
    end
  end
end
