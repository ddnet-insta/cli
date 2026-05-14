# frozen_string_literal: true

# Item that can be selected
# used for cli menus
class Item
  attr_reader :value, :name, :description, :key

  def initialize(opts = {})
    @value = opts[:value]
    @name = opts[:name]
    @key = opts[:key] || opts[:name]
    @description = opts[:description]
    @default = opts[:default] || false
  end

  def default?
    @default
  end

  def self.find(items, name)
    match = items.find { |item| item.key == name }
    return match unless match.nil?

    items.find { |item| item.name == name }
  end
end
