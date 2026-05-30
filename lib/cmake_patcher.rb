# frozen_string_literal: true

class CMakePatcher
  SERVER_PREFIX = 'src/insta/server'

  def initialize(opts = {})
    @cmake_path = opts[:path]
    @cmake_content = opts[:content]

    @cmake_path = 'CMakeLists.txt' if @cmake_content.nil? && @cmake_path.nil?
    raise "cmake file not found: #{@cmake_path}" if !@cmake_path.nil? && !File.exist?(@cmake_path)

    @new_files = []

    # bit weird that this is an array xd
    # we should really never create multiple forks at once but eh whatever
    @forks = []
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

  # create a ddnet-insta fork that has a different name
  # it will live in its own folder with its own CMakeLists.txt
  # and the cmake patcher will include that new cmake file
  # in the main cmake file in the right places
  #
  # @param name [String] name of the fork
  def add_fork(name)
    @forks << name
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
      ######################
      # patch source lists #
      ######################
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

      #   set_src(INSTA_SERVER GLOB_RECURSE src/insta/server
      in_set_src = true if line.match?(/set_src.INSTA_SERVER.*src.insta.server/)

      ##############
      # patch fork #
      ##############
      case line
      when 'include("${CMAKE_CURRENT_SOURCE_DIR}/src/insta/CMakeLists.txt")'
        new_content += "#{line}\n"
        @forks.each do |fork|
          new_content += 'include("${CMAKE_CURRENT_SOURCE_DIR}/src/' + fork + '/CMakeLists.txt")' + "\n"
        end
        next
      when 'insta_patch_engine()'
        new_content += "#{line}\n"
        @forks.each do |fork|
          new_content += "#{fork}_patch_engine()\n"
        end
        next
      when '  insta_patch_server()'
        new_content += "#{line}\n"
        @forks.each do |fork|
          new_content += "  #{fork}_patch_server()\n"
        end
        next
      end

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
  def build_files_string(old_files, indent = 6)
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
    files.sort
  end

  # @return [String] with CMakeLists.txt file content
  def content
    return @cmake_content if @cmake_path.nil?

    File.read(@cmake_path)
  end
end
