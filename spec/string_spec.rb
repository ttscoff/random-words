# frozen_string_literal: true

RSpec.describe String do
  subject(:random_words) { RandomWords::Generator.new(:english) }

  describe '.compress' do
    it 'compresses extra spaces' do
      str = %(  text   with   extra   spaces  )
      expect(str.compress).to eq('text with extra spaces')
    end
  end

  describe '.no_term' do
    it 'removes punctuation from the end of a string' do
      str = 'Hello World!'
      expect(str.no_term).to eq('Hello World')
    end

    it 'handles strings with no punctuation' do
      str = 'Hello World'
      expect(str.no_term).to eq('Hello World')
    end

    it 'handles empty strings' do
      str = ''
      expect(str.no_term).to eq('')
    end
  end

  describe '.clean' do
    it 'removes unwanted characters and whitespace' do
      str = '  Hello, World!  '
      expect(str.clean).to eq('Hello World')
    end
  end

  describe '.split_lines' do
    it 'splits a string into lines and cleans each line' do
      str = "  Hello, World!  \n\n  This is a test.  "
      expect(str.split_lines).to eq(['Hello World', 'This is a test'])
    end
  end

  describe '.terminate' do
    it 'terminates a string with a random punctuation mark' do
      str = 'Hello World'
      expect(str.terminate(["(", ")"])).to match(/\(Hello World\)$/)
    end
  end

  describe '.to_sent' do
    it 'converts a string to a sentence format' do
      str = 'hello World'
      expect(str.to_sent(["", "."])).to eq('Hello World.')
    end
  end

  describe '.fix_caps' do
    it 'capitalizes the first letter of each sentence' do
      str = 'hello world. this is a test.'
      expect(str.fix_caps([["", "."]])).to eq('Hello world. This is a test.')
    end

    it 'handles strings with no sentences' do
      str = 'hello world'
      expect(str.fix_caps([["", "."]])).to eq('Hello world')
    end

    it 'handles empty strings' do
      str = ''
      expect(str.fix_caps([["", "."]])).to eq('')
    end
  end

  describe '.dedup_commas' do
    it 'removes duplicate commas' do
      str = 'Hello,, World!'
      expect(str.dedup_commas).to eq('Hello, World!')
    end

    it 'handles strings with no commas' do
      str = 'Hello, , World'
      expect(str.dedup_commas).to eq('Hello, World')
    end

    it 'handles empty strings' do
      str = ''
      expect(str.dedup_commas).to eq('')
    end
  end

  describe '.capitalize_i' do
    it 'capitalizes "i" when it is a standalone word' do
      str = 'i am here'
      expect(str.capitalize_i).to eq('I am here')
    end

    it 'does not capitalize "i" when it is part of a word' do
      str = 'this is it'
      expect(str.capitalize_i).to eq('this is it')
    end
  end

  describe '.capitalize' do
    it 'capitalizes the first letter of a string' do
      str = 'hello world'
      expect(str.capitalize).to eq('Hello world')
    end

    it 'handles strings that are already capitalized' do
      str = 'Hello world'
      expect(str.capitalize).to eq('Hello world')
    end

    it 'handles strings with leading punctuation' do
      str = '"hello world"'
      expect(str.capitalize).to eq('"Hello world"')
    end

    it 'handles strings with mixed case, only capitalizing the first letter' do
      str = 'hElLo WoRlD'
      expect(str.capitalize).to eq('HElLo WoRlD')
    end

    it 'handles empty strings' do
      str = ''
      expect(str.capitalize).to eq('')
    end
  end
end
