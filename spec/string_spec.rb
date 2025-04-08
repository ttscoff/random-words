# frozen_string_literal: true

RSpec.describe String do
  describe '.compress' do
    it 'compresses extra spaces' do
      str = %(  text   with   extra   spaces  )
      expect(str.compress).to eq('text with extra spaces')
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
      expect(str.terminate).to match(/Hello World[.!?]$/)
    end
  end
end
