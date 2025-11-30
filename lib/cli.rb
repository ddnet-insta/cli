#!/usr/bin/env ruby

require_relative 'code_generation'

class Cli
  def initialize
    mode = Gamemode.new(
      name: 'placeholder'
    )
    # puts mode.gen_cpp_header

    puts mode.write_cpp_header
    puts mode.write_cpp_source
  end
end

cli = Cli.new
