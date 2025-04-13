# frozen_string_literal: true

RSpec.describe RandomWords::Generator do
  describe '#initialize' do
    subject(:generator) { described_class.new(:english) }

    it 'sets default source to :english' do
      expect(generator.source).to eq(:english)
    end

    it 'loads word lists from files' do
      expect(generator.nouns).to be_an(Array)
      expect(generator.verbs).to be_an(Array)
      expect(generator.adjectives).to be_an(Array)
      expect(generator.adverbs).to be_an(Array)
    end

    it 'sets default sentence length to :medium' do
      expect(generator.instance_variable_get(:@options)[:sentence_length]).to eq(:medium)
    end

    it 'sets default paragraph length to 5' do
      expect(generator.instance_variable_get(:@options)[:paragraph_length]).to eq(5)
    end

    context 'with custom source' do
      subject(:generator) { described_class.new(:french) }

      it 'sets custom source' do
        expect(generator.source).to eq(:french)
      end
    end

    context 'with custom options' do
      subject(:generator) { described_class.new(:english, sentence_length: :short, paragraph_length: 3) }

      it 'sets custom options' do
        expect(generator.instance_variable_get(:@options)[:sentence_length]).to eq(:short)
        expect(generator.instance_variable_get(:@options)[:paragraph_length]).to eq(3)
      end
    end
  end
end
