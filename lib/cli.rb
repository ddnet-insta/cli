#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'code_generation'

class Cli
  def initialize(args)
    parse_args(args)
    # helps "gets"
    # https://stackoverflow.com/a/2166914
    ARGV.clear

    mode = Gamemode.new(
      name: @args[:name]
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

        @args[:name] = arg
      end
    end

    validate_args
  end

  def validate_args
    raise 'Controller name can not be empty' if @args[:name].nil? || @args[:name].empty?
  end
end

Cli.new(ARGV)
