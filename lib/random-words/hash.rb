# frozen_string_literal: true

class ::Hash
  # Turn all keys into symbols
  def symbolize_keys
    each_with_object({}) { |(k, v), hsh| hsh[k.to_sym] = v.is_a?(Hash) ? v.symbolize_keys : v }
  end

  # Turn all keys into strings
  def stringify_keys
    each_with_object({}) { |(k, v), hsh| hsh[k.to_s] = v.is_a?(Hash) ? v.stringify_keys : v }
  end
end