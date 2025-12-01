#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'code_generation'

class Cli
  def initialize(args)
    parse_args(args)
    # helps "gets"
    # https://stackoverflow.com/a/2166914
    ARGV.clear
  end

  def run
    parent = Controller.base_pvp

    # # interactive picker is not polished yet but works
    # # there should also be a non interactive version
    # # by passing like controller_name:parent_name as cli arg
    # parent = pick_item(Controller.parents).value

    if @args[:parent]
      parent = item_by_name(Controller.parents, @args[:parent]).value
      options = Controller.parents.map(&:name).join(', ')
      raise "Parent controller '#{@args[:parent]}' not found. Options: #{options}" if parent.nil?
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
    puts 'usage: cli [controller_name]'
    puts 'description:'
    puts '  generates the source and header file'
    puts '  for the controller'
  end

  # Interactive menu to pick an item
  #
  # @param items [Array<Item>] list of item instances to choose from
  # @return [Item] selected item
  def pick_item(items)
    # TODO: add fuzzy search and arrow key navigation

    loop do
      items.each_with_index do |item, idx|
        puts "#{idx}. #{item.name} - #{item.description}"
      end
      print '> '
      choice = $stdin.gets.to_i
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

    validate_args
  end

  def validate_args
    raise 'Controller name can not be empty' if @args[:name].nil? || @args[:name].empty?
  end
end

Cli.new(ARGV).run
