#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'gamemode'

class Cli
  def initialize(args)
    parse_args(args)
    # helps "gets"
    # https://stackoverflow.com/a/2166914
    ARGV.clear
  end

  def run
    parent = Controller.base_pvp
    if @args[:parent]
      parent = item_by_name(Controller.parents, @args[:parent])
      options = Controller.parents.map(&:name).join(', ')
      raise "Parent controller '#{@args[:parent]}' not found. Options: #{options}" if parent.nil?

      parent = parent.value
    else
      puts 'Choose your parent controller'
      # passing parent as a string if we already have an object is hacky
      @args[:parent] = pick_item(Controller.parents).value.name.to_snake
    end

    mode = Gamemode.new(
      name: @args[:name],
      parent: parent
    )
    # puts mode.gen_cpp_header
    # puts mode.gen_cpp_source

    mode.write_cpp_header
    mode.write_cpp_source
    mode.write_cmake
  end

  def show_help
    puts 'usage: ./scripts/cli [controller_name][:parent_controller]'
    puts 'description:'
    puts '  generates the source and header file'
    puts '  for the controller'
    puts 'examples:'
    puts '  ./scripts/cli zombie_party:base_pvp'
    puts '  ./scripts/cli my_new_mode:insta_core'
  end

  # Interactive menu to pick an item
  #
  # @param items [Array<Item>] list of item instances to choose from
  # @return [Item] selected item
  def pick_item(items)
    # TODO: add fuzzy search and arrow key navigation

    loop do
      items.each_with_index do |item, idx|
        default_note = item.default? ? ' (default)' : ''
        puts "#{idx}. #{item.name}#{default_note} - #{item.description}"
      end

      choice = nil
      default_item = items.find(&:default?)
      if default_item
        print '> '
        val = $stdin.gets.chomp
        unless val.match?(/^\d+$/)
          puts "Defaulted to #{default_item.name}"
          return default_item
        end

        choice = val
      else
        choice = gets_number
      end

      item = items[choice]
      return item unless item.nil?

      puts 'Invalid index!'
    end
  end

  # TODO: move these item methods to the item.rb file? idk
  def item_by_name(items, name)
    items.find { |item| item.name == name }
  end

  ## TODO: add unit tests once the args are finalized
  def parse_args(args)
    @args = {}

    until args.empty?
      arg = args.shift

      case arg
      when 'h', '-h', '--help', 'help', 'bruder was', '???', '?'
        show_help
        exit 0
      when /^--/
        raise "Unknown option '#{arg}'"
      when /^-/
        raise "Unknown flag '#{arg}'"
      else
        raise "Unexpected argument '#{arg}'" unless @args[:name].nil?

        name = arg
        if name.include?(':')
          parts = name.split(':')
          @args[:name] = parts.shift
          @args[:parent] = parts.join(':')
        else
          @args[:name] = name
        end
      end
    end

    fetch_args_interactive if @args[:name].nil?
  end

  def gets_non_empty
    loop do
      print '> '
      val = $stdin.gets.chomp
      return val unless val.empty?

      puts 'Value can not be empty. Please try again.'
    end
  end

  def gets_number
    loop do
      print '> '
      val = $stdin.gets.chomp
      return val.to_i if val.match?(/^\d+$/)

      puts 'Please provide a valid number'
    end
  end

  def gets_snake_case
    loop do
      print '> '
      val = $stdin.gets.chomp
      return val if val.lower_snake_case?

      puts 'Value has to be lower_snake_caase. Please try again.'
    end
  end

  def fetch_args_interactive
    puts 'Choose your controller name (use lower_snake_case)'
    @args[:name] = gets_snake_case

    puts 'Choose your parent controller'
    # passing parent as a string if we already have an object is hacky
    @args[:parent] = pick_item(Controller.parents).value.name.to_snake
  end
end

Cli.new(ARGV).run
