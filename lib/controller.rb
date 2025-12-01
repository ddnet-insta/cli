# frozen_string_literal: true

require_relative 'strings'
require_relative 'colors'
require_relative 'cmake_patcher'
require_relative 'item'

# comments use YARD format
# https://rubydoc.info/gems/yard/file/docs/GettingStarted.md

CONTROLLER_BASE_DIR_INCLUDE = 'game/server/gamemodes'
CONTROLLER_BASE_DIR_FS = "src/#{CONTROLLER_BASE_DIR_INCLUDE}".freeze

class Controller
  @base_pvp_controller = nil
  @insta_core_controller = nil

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

  def self.base_pvp
    return @base_pvp_controller if @base_pvp_controller

    @base_pvp_controller = Controller.new(
      name: 'base_pvp'
    )
  end

  def self.insta_core
    return @insta_core_controller if @insta_core_controller

    @insta_core_controller = Controller.new(
      name: 'insta_core'
    )
  end

  # @return [Array<Item>]
  def self.parents
    [
      Item.new(
        default: true,
        name: 'base_pvp',
        value: base_pvp,
        description: 'Basic pvp controller. Top recommendation!'
      ),
      Item.new(
        name: 'insta_core',
        value: insta_core,
        description: "
          Most minimal controller implementing only basic ddnet-insta,
          might be missing essential features. Only for advanced users.
        ".squeeze(' ').gsub("\n", '')
      )
    ]
  end
end
