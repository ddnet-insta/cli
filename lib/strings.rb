# frozen_string_literal: true

class String
  def snake_to_camel
    split('_').map(&:capitalize).join
  end

  def camel_to_snake
    split(/([A-Z][a-z]*)/).each_slice(2).map(&:join).map(&:downcase).join('_')
  end

  def to_camel
    return snake_to_camel if match?(/_/)
    return capitalize if downcase == self

    self
  end

  def to_snake
    return self if match?(/_/)

    camel_to_snake
  end
end
