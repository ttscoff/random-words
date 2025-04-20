# frozen_string_literal: true

# Original code by Mike Burns

# Copyright 2007 Mike Burns

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

module RandomWords
  # This class extends the Integer class with methods to convert numbers
  # into their word representations. It provides methods for converting
  # numbers to words in various languages, including English.
  #
  # @example
  #   1.to_word # => "one"
  #   126620.to_word # => "one hundred twenty six thousand six hundred twenty"
  #
  class ::Integer
    # Turn a number into the word representation of that number.
    #  1.to_word      # => "one"
    #  126620.to_word # => "one hundred twenty six thousand six hundred twenty"
    def to_word(numbers)
      tmp = self / 1000
      final = (self % 1000).hundred_to_word(2, numbers)
      place = 3 # special-case the tens and below
      until tmp.zero?
        final = (tmp % 1000).hundred_to_word(place, numbers) + ' ' + final
        place += 1
        tmp /= 1000
      end
      final == '' ? 'zero' : final.sub(/\s+$/, '')
    end

    # For testing edge cases
    def additional_tests(numbers)
      teen_to_word(numbers)
      digit_to_word(numbers)
      tens_place_to_word(numbers)
      true
    end

    # protected

    # Convert a number to its word representation for the hundreds place.
    def hundred_to_word(place = 0, numbers)
      if zero?
        ''
      elsif self < 10
        append_place(digit_to_word(numbers), place, numbers)
      elsif self < 20
        append_place(teen_to_word(numbers), place, numbers)
      elsif self < 100
        append_place(tens_place_to_word(numbers), place, numbers)
      else
        hundreds = self / 100
        tens = self % 100
        if tens.zero?
          append_place(hundreds.digit_to_word(numbers) + " #{numbers[:places][2]} and ", place, numbers)
        else
          append_place(hundreds.digit_to_word(numbers) + " #{numbers[:places][2]} and " + tens.tens_place_to_word(numbers), place,
                       numbers)
        end
      end
    end

    # Append the appropriate place value to a word based on its position.
    # @param word [String] The word representation of the number.
    # @param place [Integer] The place value (e.g., hundreds, thousands).
    # @param numbers [Hash] A hash containing number words.
    # @return [String] The word with the appropriate place value appended.
    def append_place(word, place, numbers)
      places = numbers[:places]
      if place > 2
        word + ' ' + places[place]
      else
        word
      end
    end

    # Convert a number to its word representation for the tens place.
    # This is a special case for numbers 20-99.
    # @param numbers [Hash] A hash containing number words.
    # @return [String] The word representation of the number.
    # @example
    #   45.tens_place_to_word(numbers) # => "forty five"
    def tens_place_to_word(numbers)
      if self > 19
        tens = self / 10
        ones = self % 10
        ten = numbers[:tens][tens - 2]
        ten + (ones.zero? ? '' : ' ' + ones.digit_to_word(numbers))
      else
        teen_to_word(numbers)
      end
    end

    # Convert a number to its word representation for the teens place.
    # This is a special case for numbers 10-19.
    # @param numbers [Hash] A hash containing number words.
    # @return [String] The word representation of the number.
    # @example
    #   12.teen_to_word(numbers) # => "twelve"
    def teen_to_word(numbers)
      if self < 10
        digit_to_word(numbers)
      elsif self < 20
        numbers[:teens][self - 10]
      else
        tens_place_to_word(numbers)
      end
    end

    # Convert a number to its word representation for the digits place.
    # This is a special case for numbers 0-9.
    # @param numbers [Hash] A hash containing number words.
    # @return [String] The word representation of the number.
    # @example
    #   5.digit_to_word(numbers) # => "five"
    def digit_to_word(numbers)
      if zero?
        ''
      else
        numbers[:digits][self]
      end
    end
  end
end
