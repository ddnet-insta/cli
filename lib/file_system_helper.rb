# frozen_string_literal: true

require 'fileutils'

require_relative 'strings'
require_relative 'colors'
require_relative 'cmake_patcher'
require_relative 'item'

# yes yes horrible class name
# what u gonna do
class FileSystemHelper
  # Writes to file with an interactive warning
  # before overwriting an old file
  #
  # does not create base path
  #
  # @param path [String] file path to write to
  # @param text [String] text to be written to file
  #
  # @return [true, false] true if written
  def write?(path, text)
    return false unless ok_to_overwrite? path

    File.write(path, text)
    puts "[*] created file #{path.green}"
    true
  end

  def ok_to_overwrite?(path)
    return true unless File.exist? path

    puts "[!] the following file already exists #{path}"
    puts '[!] do you really want to overwrite it? (y/N)'
    return true if $stdin.gets.chomp.match?(/[Yy](es)?/)

    puts '[!] skipping file ...'
    false
  end
end
