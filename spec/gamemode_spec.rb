# frozen_string_literal: true

require 'fileutils'

require_relative '../lib/gamemode'

describe 'Gamemode', :array do
  context 'simple' do
    it 'Should generate code without crashing' do
      FileUtils.mkdir_p 'spec/tmp'
      FileUtils.cp('spec/cmake/simple.cmake.in', 'spec/tmp/CMakeLists.txt')
      mode = Gamemode.new(
        name: 'simple',
        parent: Controller.base_pvp,
        cmake_path: 'spec/tmp/CMakeLists.txt'
      )
      mode.gen_cpp_header
      mode.gen_cpp_source
      FileUtils.rm_rf('spec/tmp')
    end
  end
end
