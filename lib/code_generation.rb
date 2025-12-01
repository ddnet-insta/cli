# frozen_string_literal: true

require 'fileutils'

require_relative 'strings'
require_relative 'colors'
require_relative 'cmake_patcher'

# comments use YARD format
# https://rubydoc.info/gems/yard/file/docs/GettingStarted.md

CONTROLLER_BASE_DIR_INCLUDE = 'game/server/gamemodes'
CONTROLLER_BASE_DIR_FS = "src/#{CONTROLLER_BASE_DIR_INCLUDE}".freeze

class Controller
  @pvp_controller = nil

  attr_reader :path

  def initialize(opts = {})
    # class name
    @name = opts[:name]
    raise 'Name can not be empty!' if @name.empty?
    raise 'Name can not start with an underscore!' if @name.start_with?('_')

    @name = @name.to_camel

    # relative path from CONTROLLER_BASE_DIR_FS
    @path = opts[:path] || opts[:name].split('/')
    raise "Path has to be an array! Got #{@path.class} #{@path} instead" unless @path.is_a?(Array)

    # [String] filename base without extension
    @filename = opts[:filename] || opts[:name]
    raise 'Filename can not be empty!' if @filename.nil? || @filename.empty?
    raise "Invalid filename: #{@filename}" if @filename.include? '.'

    @filename = @filename.to_snake
  end

  # camel cased name
  attr_reader :name

  def class_name
    "CGameController#{@name}"
  end

  def name_snake
    @name.to_snake
  end

  # @return [String] controller header filename
  def header_filename
    "#{@filename}.h"
  end

  # @return [String] controller cpp source filename
  def source_filename
    "#{@filename}.cpp"
  end

  def include_path_abs
    "#{CONTROLLER_BASE_DIR_INCLUDE}/#{@path.join('/')}/#{header_filename}"
  end

  def self.pvp
    return @pvp_controller if @pvp_controller

    @pvp_controller = Controller.new(
      name: 'base_pvp'
    )
  end

  # TODO: create user facing dropdown with this
  #       so we can pick a parent controller
  def self.list
    {
      pvp: {
        controller: pvp,
        description: 'Basic pvp controller. Top recommendation!'
      }
    }
  end
end

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

class Gamemode
  def initialize(opts = {})
    opts[:filename] = opts[:name] if opts[:filename].nil?
    @controller = Controller.new(opts)

    # camel name of parent controller
    @parent_controller = Controller.pvp

    @fs = FileSystemHelper.new
    @cmake = CMakePatcher.new
  end

  def write_cpp_header
    # create folder
    dir = fs_create_base_dir

    # create file
    path = "#{dir}/#{@controller.header_filename}"
    return unless @fs.write?(path, gen_cpp_header)

    @cmake.add_file(path)
  end

  def write_cpp_source
    # create folder
    dir = fs_create_base_dir

    # create file
    path = "#{dir}/#{@controller.source_filename}"
    return unless @fs.write?(path, gen_cpp_source)

    @cmake.add_file(path)
  end

  def write_cmake
    puts "[*] adding files to #{'CMakeLists.txt'.green}"
    @cmake.save
  end

  # @return [String] gamemode.h C++ source code
  def gen_cpp_header
    [
      include_guard_open,
      '',
      "#include <#{@parent_controller.include_path_abs}>",
      '',
      "class #{@controller.class_name} : public #{@parent_controller.class_name}",
      '{',
      'public:',
      "	#{@controller.class_name}(CGameContext *pGameServer);",
      "	~#{@controller.class_name}() override;",
      '',
      header_methods,
      '};',
      include_guard_close
    ].join("\n") + "\n"
  end

  # @return [String] gamemode.cpp C++ source code
  def gen_cpp_source
    [
      "#include \"#{@controller.header_filename}\"",
      '',
      '#include <game/server/entities/character.h>',
      '#include <game/server/gamecontext.h>',
      '#include <game/server/player.h>',
      '',
      "#{@controller.class_name}::#{@controller.class_name}(CGameContext *pGameServer) :",
      "	#{@parent_controller.class_name}(pGameServer)",
      '{',
      constructor_body,
      '}',
      '',
      "#{@controller.class_name}::~#{@controller.class_name}() = default;",
      '',
      source_methods,
      "REGISTER_GAMEMODE(#{@controller.name_snake}, #{@controller.class_name}(pGameServer));"
    ].join("\n") + "\n"
  end

  private

  def fs_create_base_dir
    raise "Missing directory: #{CONTROLLER_BASE_DIR_FS}" unless Dir.exist? CONTROLLER_BASE_DIR_FS

    # create directory
    dir = "#{CONTROLLER_BASE_DIR_FS}/#{@controller.path.join('/')}"
    FileUtils.mkdir_p dir
    dir
  end

  def constructor_body
    [
      '// if you do not need team red/blue or the red and blue flag from ctf',
      '// just do m_GameFlags = 0;',
      'm_GameFlags = GAMEFLAG_TEAMS | GAMEFLAG_FLAGS;',
      "m_pGameType = \"#{@controller.name_snake}\";",
      'm_DefaultWeapon = WEAPON_GUN;',
      '',
      "m_pStatsTable = \"#{@controller.name_snake}\";",
      "m_pExtraColumns = nullptr; // new C#{@controller.name}Columns();",
      'm_pSqlStats->SetExtraColumns(m_pExtraColumns);',
      'm_pSqlStats->CreateTable(m_pStatsTable);'
    ].map { |m| "\t#{m}" }.join("\n")
  end

  def include_guard_open
    slug = @controller.path.map(&:upcase).join('_')
    slug += '_' unless slug.empty?
    slug += @controller.name.to_snake.upcase
    [
      "#ifndef GAME_SERVER_GAMEMODES_#{slug}_H",
      "#define GAME_SERVER_GAMEMODES_#{slug}_H"
    ].join("\n")
  end

  def include_guard_close
    '#endif'
  end

  def source_methods
    # TODO: the header and source methods should be be kept in sync with some kind of data structure
    #       that matches methods by name
    #       and then writes the correct signatures
    #       and these signatures should be fetched from the source code
    #       not hardcodet in here
    [
      '// TODO: add methods here, but they should be dynamic',
      '',
      "void #{@controller.class_name}::OnInit()",
      empty_method_body('void'),
      "int #{@controller.class_name}::OnCharacterDeath(CCharacter *pVictim, class CPlayer *pKiller, int Weapon)",
      empty_method_body('int')
    ].join("\n")
  end

  def empty_method_body(return_type)
    lines = ['{']
    case return_type
    when 'void' then nil
    when 'int' then lines << "\treturn 0;"
    else raise "Unknown return type: #{return_type}"
    end
    lines << '}'
    lines << ''
    lines
  end

  def header_methods
    [
      'void OnInit() override;',
      'int OnCharacterDeath(class CCharacter *pVictim, CPlayer *pKiller, int Weapon) override;'
    ].map { |m| "\t#{m}" }.join("\n")
  end
end
