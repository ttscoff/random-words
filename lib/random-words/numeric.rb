# frozen_string_literal: true

module RandomWords
  # Number helpers
  class ::Numeric
    def to_commas
      num = to_s.reverse.scan(/(?:\d*\.)?\d{1,3}-?/).join(',').reverse
      dec = num.split('.')
      num = dec[0].to_s + '.' + dec[1].to_s.ljust(2, '0')[0,2] if dec[1]
      num
    end
  end
end