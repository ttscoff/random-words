#!/usr/bin/env ruby
# frozen_string_literal: true

class ::String
  def clean
    gsub(/[^-a-zA-Z0-9\s]/, '').strip
  end

  def clean!
    replace(clean)
  end

  def split_lines
    strip.split("\n").map(&:clean).reject(&:empty?)
  end

  def compress
    gsub(/\s+/, ' ').strip
  end

  def compress!
    dup.replace(compress)
  end
end
