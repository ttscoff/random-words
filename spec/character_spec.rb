# frozen_string_literal: true

RSpec.describe RandomWords::Generator do
  subject(:random_words) { described_class.new }

  describe '.characters' do
    it 'generates a sentence of exactly X characters' do
      res = true
      (10..100).each do |idx|
        random = random_words.characters(idx)
        unless random.is_a?(String) && random.length == idx
          res = false
          break
        end
      end

      expect(res).to be true
    end
  end
end
