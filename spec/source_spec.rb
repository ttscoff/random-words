# frozen_string_literal: true

RSpec.describe RandomWords::Source do
  subject(:source) { described_class.new(:english, File.join(__dir__, '..', 'lib', 'random-words', 'words', 'english')) }

  describe '#initialize' do
    it 'creates a new source with default values' do
      expect(source.name).to eq(:english)
    end
  end

  describe "#initialize" do
    it 'fails to load config file' do
      expect(described_class.new(:english, "invalid_path").config).to be_empty
    end
  end

  describe '#bad_init' do
    it 'returns empty array when bad filename is provided' do
      expect(source.bad_init).to be_empty
    end
  end
end
