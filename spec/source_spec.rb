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

  describe '#from_yaml' do
    let(:temp_yaml_file) { File.join(__dir__, '..', 'lib', 'random-words', 'words', 'english', 'test.yml') }

    before do
      File.write(temp_yaml_file, "one: first second\ntwo: third fourth")
    end

    after do
      File.delete(temp_yaml_file) if File.exist?(temp_yaml_file)
    end

    it 'loads and parses yaml file into hash with array values' do
      result = source.send(:from_yaml, 'test')
      expect(result).to eq({ one: ['first', 'second'], two: ['third', 'fourth'] })
    end

    it 'returns empty hash when file does not exist' do
      expect(source.send(:from_yaml, "nonexistent")).to eq({})
    end

    context 'with invalid YAML' do
      before do
        File.write(temp_yaml_file, "invalid: yaml: content")
      end

      it 'returns empty hash on YAML syntax error' do
        expect(source.send(:from_yaml, "test")).to eq({})
      end
    end
  end
end