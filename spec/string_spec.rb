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
      expect(str.no_term(random_words.terminators)).to eq('Hello World')
    end

    it 'handles strings with no punctuation' do
      str = 'Hello World'
      expect(str.no_term(random_words.terminators)).to eq('Hello World')
    end

    it 'handles empty strings' do
      str = ''
      expect(str.no_term(random_words.terminators)).to eq('')
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
      expect(str.terminate(['(', ')'])).to match(/\(Hello World\)$/)
    end
  end

  describe '.to_sent' do
    it 'converts a string to a sentence format' do
      str = 'hello World'
      expect(str.to_sent(['', '.'])).to eq('Hello World.')
    end
  end

  describe '.fix_caps' do
    it 'capitalizes the first letter of each sentence' do
      str = 'hello world. this is a test.'
      expect(str.fix_caps([['', '.']])).to eq('Hello world. This is a test.')
    end

    it 'handles strings with no sentences' do
      str = 'hello world'
      expect(str.fix_caps([['', '.']])).to eq('Hello world')
    end

    it 'handles empty strings' do
      str = ''
      expect(str.fix_caps([['', '.']])).to eq('')
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

  describe '.downcase_first' do
    it 'downcases the first letter of a string' do
      str = 'Hello World'
      expect(str.downcase_first).to eq('hello World')
    end

    it 'handles strings that are already downcased' do
      str = 'hello world'
      expect(str.downcase_first).to eq('hello world')
    end

    it 'handles strings with leading punctuation' do
      str = '"Hello world"'
      expect(str.downcase_first).to eq('"hello world"')
    end

    it 'handles strings with mixed case, only downcasing the first letter' do
      str = 'HElLo WoRlD'
      expect(str.downcase_first).to eq('hElLo WoRlD')
    end

    it 'handles empty strings' do
      str = ''
      expect(str.downcase_first).to eq('')
    end
  end

  describe '.to_source' do
    before do
      allow(RandomWords::Generator).to receive(:new).and_return(double(sources: {
                                                                         latin: double(names: [:latin]),
                                                                         greek: double(names: %i[greek hellenic], name: :greek),
                                                                         norse: double(names: %i[norse viking], name: :norse)
                                                                       }))
    end

    it 'matches source by name prefix' do
      expect('gre'.to_source).to eq(:greek)
      expect('nor'.to_source).to eq(:norse)
      expect('vik'.to_source).to eq(:norse)
    end

    it 'is case insensitive' do
      expect('GREEK'.to_source).to eq(:greek)
      expect('Norse'.to_source).to eq(:norse)
    end

    it 'returns :latin when no match found' do
      expect('invalid'.to_source).to eq(:latin)
      expect('xyz'.to_source).to eq(:latin)
    end
  end

  describe '.trueish?' do
    it 'returns true for strings starting with t' do
      expect('true'.trueish?).to be_truthy
      expect('TRUE'.trueish?).to be_truthy
      expect('test'.trueish?).to be_truthy
    end

    it 'returns true for strings starting with y' do
      expect('yes'.trueish?).to be_truthy
      expect('YES'.trueish?).to be_truthy
      expect('yellow'.trueish?).to be_truthy
    end

    it 'returns true for strings starting with 1' do
      expect('1'.trueish?).to be_truthy
      expect('123'.trueish?).to be_truthy
      expect('1test'.trueish?).to be_truthy
    end

    it 'returns false for other strings' do
      expect('false'.trueish?).to be_falsey
      expect('no'.trueish?).to be_falsey
      expect('0'.trueish?).to be_falsey
      expect(''.trueish?).to be_falsey
    end
  end

  describe '.to_length' do
    it 'returns :short for strings starting with s' do
      expect('short'.to_length).to eq(:short)
      expect('small'.to_length).to eq(:short)
      expect('S'.to_length).to eq(:short)
    end

    it 'returns :medium for strings starting with m' do
      expect('medium'.to_length).to eq(:medium)
      expect('middle'.to_length).to eq(:medium)
      expect('m'.to_length).to eq(:medium)
    end

    it 'returns :long for strings starting with l' do
      expect('long'.to_length).to eq(:long)
      expect('large'.to_length).to eq(:long)
      expect('l'.to_length).to eq(:long)
    end

    it 'returns :very_long for strings starting with v' do
      expect('very'.to_length).to eq(:very_long)
      expect('vast'.to_length).to eq(:very_long)
      expect('v'.to_length).to eq(:very_long)
    end

    it 'returns :medium as default for other strings' do
      expect('other'.to_length).to eq(:medium)
      expect('test'.to_length).to eq(:medium)
      expect(''.to_length).to eq(:medium)
    end
  end

  describe '.no_term' do
    it 'removes periods from end of string' do
      str = 'Hello World.'
      expect(str.no_term(random_words.terminators)).to eq('Hello World')
    end

    it 'removes exclamation marks from end of string' do
      str = 'Hello World!'
      expect(str.no_term(random_words.terminators)).to eq('Hello World')
    end

    it 'preserves punctuation in middle of string' do
      str = 'Hello, World!'
      expect(str.no_term(random_words.terminators)).to eq('Hello, World')
    end

    it 'handles multiple punctuation marks at end' do
      str = 'Hello World...!!!'
      expect(str.no_term(random_words.terminators)).to eq('Hello World')
    end
  end

  describe '.indent' do
    it 'indents each line with specified string' do
      str = "Hello\nWorld"
      expect(str.indent('  ')).to eq("  Hello\n  World")
    end

    it 'handles single line strings' do
      str = 'Hello'
      expect(str.indent('  ')).to eq('  Hello')
    end

    it 'handles empty strings' do
      str = ''
      expect(str.indent('  ')).to eq('  ')
    end
  end
end
