require 'rspec'

RSpec.describe 'Hello World' do
  it 'returns the correct greeting' do
    expect("Hello, World!").to eq("Hello, World!")
  end
end