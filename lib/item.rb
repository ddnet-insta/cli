# frozen_string_literal: true

# Item that can be selected
# used for cli menus
class Item
  attr_reader :value, :name, :description

  def initialize(opts = {})
    @value = opts[:value]
    @name = opts[:name]
    @description = opts[:description]
  end
end
