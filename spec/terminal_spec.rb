# frozen_string_literal: true

RSpec.describe RandomWords::Terminal do
  let(:terminal) { described_class.new }

  describe '#initialize' do
    it 'creates a new terminal with default source' do
      expect(terminal.instance_variable_get(:@sentence_generator)).to be_a(RandomWords::Generator)
      expect(terminal.instance_variable_get(:@sentence_generator).source).to eq(:english)
    end

    it 'initializes colors hash' do
      colors = terminal.instance_variable_get(:@colors)
      expect(colors).to include(
        text: :yellow,
        counter: :boldcyan,
        marker: :boldgreen,
        bracket: :cyan,
        language: :boldmagenta
      )
    end
  end

  describe '#colors' do
    it 'returns a hash of color codes' do
      expect(terminal.colors).to include(
        black: 30,
        red: 31,
        green: 32,
        yellow: 33,
        blue: 34,
        magenta: 35,
        cyan: 36,
        white: 37
      )
    end
  end

  describe '#colorize_text' do
    it 'returns unmodified text when not in terminal' do
      allow($stdout).to receive(:isatty).and_return(false)
      expect(terminal.colorize_text('test', :red)).to eq('test')
    end

    it 'adds color codes when in terminal' do
      allow($stdout).to receive(:isatty).and_return(true)
      expect(terminal.colorize_text('test', :red)).to eq("\e[31mtest\e[0m")
    end
  end

  describe '#marker' do
    it 'returns a colored bullet point' do
      allow($stdout).to receive(:isatty).and_return(true)
      expect(terminal.marker).to include('•')
    end
  end

  describe '#text' do
    it 'returns colorized text' do
      text = 'sample text'
      allow($stdout).to receive(:isatty).and_return(true)
      expect(terminal.text(text)).to include(text)
    end
  end

  describe '#counter' do
    it 'formats length counter with brackets and language' do
      allow($stdout).to receive(:isatty).and_return(true)
      expect(terminal.counter(10)).to include('10')
    end
  end

  describe '#print_test' do
    it 'prints the test message' do
      allow($stdout).to receive(:isatty).and_return(true)
      expect { terminal.print_test }.to output(/Random Characters/).to_stdout
    end
  end
end
