# frozen_string_literal: true

RSpec.describe Hash do
  describe '#symbolize_keys' do
    it 'converts string keys to symbols' do
      hash = { 'name' => 'John', 'age' => 30 }
      expect(hash.symbolize_keys).to eq({ name: 'John', age: 30 })
    end

    it 'handles nested hashes' do
      hash = { "user" => { 'name' => 'John', 'age' => 30 } }
      expect(hash.symbolize_keys).to eq({ user: { name: 'John', age: 30 } })
    end
  end

  describe '#stringify_keys' do
    it 'converts symbol keys to strings' do
      hash = { name: 'John', age: 30 }
      expect(hash.stringify_keys).to eq({ 'name' => 'John', 'age' => 30 })
    end

    it 'handles nested hashes' do
      hash = { user: { name: 'John', age: 30 } }
      expect(hash.stringify_keys).to eq({ "user" => { 'name' => 'John', 'age' => 30 } })
    end
  end
end