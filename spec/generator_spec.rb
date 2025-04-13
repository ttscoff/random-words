# frozen_string_literal: true

RSpec.describe RandomWords::Generator do
  subject(:generator) { described_class.new }
  subject(:opening_regex) {"[A-Z#{Regexp.escape(described_class.new.terminators.map { |t| t[0].split("").first }.delete_if(&:nil?).sort.uniq.join)}]"}
  subject(:closing_regex) {"[#{Regexp.escape(described_class.new.terminators.map { |t| t[1].split("").last }.delete_if(&:nil?).sort.uniq.join)}]"}
  subject(:sentence_regex) { Regexp.new("^#{opening_regex}.*?#{closing_regex}$") }

  describe '#initialize' do
    it 'creates a new generator with default values' do
      expect(generator.source).to eq(:english)
      expect(generator.lengths).to include(
        short: 20,
        medium: 60,
        long: 100,
        very_long: 300
      )
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
        short: 20,
        medium: 60,
        long: 100,
        very_long: 300
      )
    end

    it 'raises an error if length symbol is unrecognized' do
      expect { generator.bad_length }.to raise_error(ArgumentError)
    end

    it 'defines all lengths' do
      expect(generator.define_all_lengths).to eq([20, 60, 100, 300])
    end
  end

  describe '#sentence' do
    it 'generates a valid sentence' do
      result = generator.sentence
      expect(result).to match(sentence_regex)
    end
  end

  describe '#sentences' do
    it 'generates multiple sentences' do
      result = generator.sentences(3)
      expect(result).to be_an(Array)
      expect(result.length).to eq(3)
      expect(result).to all(match(sentence_regex))
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

  describe '#sentence_length=' do
    it 'updates the sentence length' do
      generator.sentence_length = :short
      expect(generator.sentence_length).to eq(:short)

      generator.sentence_length = :medium
      expect(generator.sentence_length).to eq(:medium)

      generator.sentence_length = :long
      expect(generator.sentence_length).to eq(:long)

      generator.sentence_length = :very_long
      expect(generator.sentence_length).to eq(:very_long)
    end

    it "raises an error for invalid sentence length" do
      expect { generator.sentence_length = :invalid }.to raise_error(ArgumentError)
    end
  end

  describe '#paragraph_length=' do
    it "updates the paragraph length" do
      generator.paragraph_length = 3
      expect(generator.paragraph_length).to eq(3)
    end

    it "raises an error for invalid paragraph length" do
      expect { generator.paragraph_length = -1 }.to raise_error(ArgumentError)
    end
  end

  describe '#create_dictionary' do
    it 'calls create_user_dictionary on config' do
      generator = described_class.new
      expect(generator.instance_variable_get(:@config)).to receive(:create_user_dictionary).with('test_dict')
      generator.create_dictionary('test_dict')
    end
  end

  describe '#generate_combined_sentence' do
  it 'generates a valid sentence that matches sentence regex' do
    result = generator.send(:generate_combined_sentence)
    expect(result).to match(sentence_regex)
  end

  it 'generates sentence at requested length' do
    result = generator.send(:generate_combined_sentence, 50)
    expect(result.length).to be >= 50
  end

  it 'combines sentences when length is insufficient' do
    short_result = generator.send(:generate_combined_sentence, 1000)
    expect(short_result.scan(/,/).count).to be >= 1
    expect(short_result).to include(" and ")
  end

  it 'returns single sentence when length is sufficient' do
    long_result = generator.send(:generate_combined_sentence, 1)
    expect(long_result.scan(sentence_regex).count).to eq(1)
  end

  it 'properly capitalizes and terminates combined sentences' do
    result = generator.send(:generate_combined_sentence)
    expect(result).to match(sentence_regex)
  end
end
end
