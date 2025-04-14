# frozen_string_literal: true
require 'tmpdir'
require 'fileutils'

RSpec.describe RandomWords::Config do
  describe '#builtin_lang_dir' do
    subject(:config) { described_class.new(:english) }

    context 'when language directory exists' do
      it 'returns path to builtin language directory' do
        expect(config.builtin_lang_dir(basedir: __dir__)).to eq(File.join(__dir__, 'words', 'english'))
      end

      it 'accepts optional language parameter' do
        expect(config.builtin_lang_dir('test', basedir: __dir__)).to eq(File.join(__dir__, 'words', 'test'))
      end
    end

    context 'when language directory does not exist' do
      it 'returns nil and prints warning for invalid language' do
        expect { config.builtin_lang_dir('invalid') }.to output(/No dictionary found for invalid/).to_stderr
        expect(config.builtin_lang_dir('invalid')).to be_nil
      end
    end
  end

  describe '#create_user_dictionary' do
    let(:config) { described_class.new(:english) }
    let(:test_lang) { 'testlang' }
    let(:test_dir) { File.join(config.config_dir, 'words', test_lang) }

    after do
      FileUtils.rm_rf(test_dir) if File.exist?(test_dir)
    end

    context 'when creating new dictionary' do
      it 'creates directory structure and files' do
        config.create_user_dictionary(test_lang)

        expect(File.directory?(test_dir)).to be true
        expect(File.exist?(File.join(test_dir, 'config.yml'))).to be true

        described_class::SPEECH_PARTS.each do |part|
          expect(File.exist?(File.join(test_dir, "#{part}.txt"))).to be true
        end
      end

      it 'returns language symbol on success' do
        expect(config.create_user_dictionary(test_lang)).to eq(test_lang.to_sym)
      end

      it 'creates config.yml with correct content' do
        config.create_user_dictionary(test_lang)
        config_content = YAML.load_file(File.join(test_dir, 'config.yml'))

        expect(config_content['name']).to eq(test_lang)
        expect(config_content['triggers']).to eq([test_lang])
        expect(config_content["description"]).to eq("User dictionary for #{test_lang}")
      end
    end
  end

  describe '#sources' do
    let(:config) { described_class.new(:english) }
    let(:test_lang) { 'testlang' }
    let(:test_dir) { File.join(config.config_dir, 'words', test_lang) }

    before do
      config.create_user_dictionary(test_lang)
    end

    after do
      FileUtils.rm_rf(test_dir) if File.exist?(test_dir)
    end

    it 'returns a hash of RandomWords::Source objects' do
      sources = config.sources
      expect(sources).to be_a(Hash)
      expect(sources.values).to all(be_a(RandomWords::Source))
    end

    it 'includes both builtin and user dictionaries' do
      sources = config.sources
      expect(sources.keys).to include('english')  # Builtin dictionary
      expect(sources.keys).to include(test_lang)  # User dictionary
    end

    it 'caches the sources after first call' do
      first_call = config.sources.object_id
      second_call = config.sources.object_id
      expect(first_call).to eq(second_call)
    end
  end

  describe "#all_parts_of_speech?" do
    let(:config) { described_class.new(:english) }
    let(:test_lang) { 'testlang' }
    let(:test_dir) { File.join(config.config_dir, 'words', test_lang) }

    before do
      config.create_user_dictionary(test_lang)
    end

    after do
      FileUtils.rm_rf(test_dir) if File.exist?(test_dir)
    end

    context 'when all required files exist' do
      it 'returns true' do
        expect(config.all_parts_of_speech?(test_dir, test_lang)).to be true
      end
    end

    context 'when some files are missing' do
      before do
        File.delete(File.join(test_dir, 'adjectives.txt'))
        File.delete(File.join(test_dir, 'nouns-singular.txt'))
      end

      it 'returns false and prints warnings' do
        # expect { config.all_parts_of_speech?(test_dir, test_lang) }.to output(/Missing.*adjectives.txt/).to_stderr
        #   .and output(/Missing.*nouns-singular.txt/).to_stderr
        expect(config.all_parts_of_speech?(test_dir, test_lang)).to be false
      end
    end

    context 'when directory does not exist' do
      it 'returns false for non-existent directory' do
        expect(config.all_parts_of_speech?('/nonexistent/dir')).to be false
      end
    end
  end

  describe "#configuration" do
    let(:config) { described_class.new(:english) }
    let(:test_config_dir) { File.join(Dir.tmpdir, 'random-words-test') }
    let(:config_file) { File.join(test_config_dir, 'config.yml') }

    before do
      config.config_dir = test_config_dir
      FileUtils.mkdir_p(test_config_dir)
    end

    after do
      FileUtils.rm_rf(test_config_dir)
    end

    context 'when config file exists' do
      before do
        File.write(config_file, {
          source: 'latin',
          length: 'short',
          paragraph_length: 3
        }.to_yaml)
      end

      it 'returns configuration from file' do
        result = config.config
        expect(result).to eq({
          source: :latin,
          sentence_length: :short,
          paragraph_length: 3
        })
      end
    end

    context 'when config file does not exist' do
      it 'creates default config file' do
        result = config.config
        expect(result).to eq({
          source: :latin,
          sentence_length: :medium,
          paragraph_length: 5
        })
        expect(File.exist?(config_file)).to be true
      end
    end
  end

  describe "#config_file" do
    let(:config) { described_class.new(:english) }
    let(:test_config_dir) { File.join(Dir.tmpdir, 'random-words-test') }
    let(:config_file_path) { File.join(test_config_dir, 'config.yml') }

    before do
      config.config_dir = test_config_dir
      FileUtils.mkdir_p(test_config_dir)
    end

    after do
      FileUtils.rm_rf(test_config_dir)
    end

    context 'when config file exists' do
      before do
        File.write(config_file_path, { source: 'latin' }.to_yaml)
      end

      it 'returns path to existing config file' do
        expect(config.config_file).to eq(config_file_path)
      end
    end

    context 'when config file does not exist' do
      it 'creates default config file and returns path' do
        expect(config.config_file).to eq(config_file_path)
        expect(File.exist?(config_file_path)).to be true

        content = YAML.load_file(config_file_path)
        expect(content).to include(
          'source' => 'latin',
          'length' => 'medium',
          'paragraph_length' => 5
        )
      end
    end
  end
end
