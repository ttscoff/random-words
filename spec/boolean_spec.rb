# frozen_string_literal: true

RSpec.describe 'Boolean extensions' do
  describe 'FalseClass' do
    subject(:false_value) { false }

    describe '#to_s' do
      it 'returns "false" as string' do
        expect(false_value.to_s).to eq('false')
      end
    end

    describe '#to_i' do
      it 'returns 0' do
        expect(false_value.to_i).to eq(0)
      end
    end

    describe '#to_f' do
      it 'returns 0.0' do
        expect(false_value.to_f).to eq(0.0)
      end
    end

    describe '#trueish?' do
      it 'returns false' do
        expect(false_value.trueish?).to be false
      end
    end
  end

  describe 'TrueClass' do
    subject(:true_value) { true }

    describe '#to_s' do
      it 'returns "true" as string' do
        expect(true_value.to_s).to eq('true')
      end
    end

    describe '#to_i' do
      it 'returns 1' do
        expect(true_value.to_i).to eq(1)
      end
    end

    describe '#to_f' do
      it 'returns 1.0' do
        expect(true_value.to_f).to eq(1.0)
      end
    end

    describe '#trueish?' do
      it 'returns true' do
        expect(true_value.trueish?).to be true
      end
    end
  end
end
