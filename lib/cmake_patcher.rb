# frozen_string_literal: true

class CMakePatcher
  SERVER_PREFIX = 'src/game/server'

  def initialize(opts = {})
    @cmake_path = opts[:path]
    @cmake_content = opts[:content]

    @cmake_path = 'CMakeLists.txt' if @cmake_content.nil? && @cmake_path.nil?
    raise "cmake file not found: #{@cmake_path}" if !@cmake_path.nil? && !File.exist?(@cmake_path)

    @new_files = []
  end

  # add a new controller source or header path
  # it will not be added to the cmakelists
  # until you call `save` to reduce writes
  #
  # @param path [String] path to controller file starting with src/
  def add_file(path)
    unless path.start_with? "#{SERVER_PREFIX}/gamemodes"
      raise "Path has to start with #{SERVER_PREFIX}/gamemodes invalid path: #{path}"
    end

    @new_files << path
  end

  # writes to disk
  def save
    raise 'CMakePatcher can not save if there is no :path give!' if @cmake_path.nil?

    File.write(@cmake_path, build_new_cmake)
  end

  # Patches the cmakelists file
  #
  # @return [String] with CMakeLists.txt file content
  def build_new_cmake
    new_content = ''
    in_set_src = false

    old_files = []

    content.split("\n").each do |line|
      if in_set_src
        if line.include?(')')
          in_set_src = false
          new_content += build_files_string(old_files)
          new_content += "\n"
        else
          old_files << line.strip
          next
        end
      end

      #   set_src(GAME_SERVER GLOB_RECURSE src/game/server
      in_set_src = true if line.match?(/set_src.GAME_SERVER.*src.game.server/)

      new_content += "#{line}\n"
    end
    new_content
  end

  private

  # Given a list of the old files it builds the new string
  # that is properly indented and sorted
  # with the new files being added
  #
  # @param old_files [Array<String>] The files currently in CMakeListst.txt
  # @param indent [Integer] Amount of spaces to indent from the beginning of the line
  # @return [Array<String>]
  def build_files_string(old_files, indent = 4)
    old_files = old_files.map(&:strip)
    new_files = @new_files.map { |file| file.delete_prefix("#{SERVER_PREFIX}/") }
    # could also delete files here
    # once we support reverting actions
    new_files = sort_files(old_files + new_files)
    new_files.map do |file|
      spaces = ' ' * indent
      "#{spaces}#{file}"
    end.join("\n")
  end

  # Sort source file names in the way
  # cmake wants them to be sorted
  # alphabetically
  #
  # @param files [Array<String>]
  # @return [Array<String>]
  def sort_files(files)
    # TODO: does this really match the cmake sorter?
    #       test the edge cases
    files.sort
  end

  # @return [String] with CMakeLists.txt file content
  def content
    return @cmake_content if @cmake_path.nil?

    File.read(@cmake_path)
  end
end
