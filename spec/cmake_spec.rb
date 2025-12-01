# frozen_string_literal: true

require 'fileutils'

require_relative '../lib/cmake_patcher'

describe 'CMakePatcher', :array do
  context 'simple' do
    it 'Should not modify' do
      input_cmake = <<~EOF
        if(SERVER)
          set_src(GAME_SERVER GLOB_RECURSE src/game/server
            gamemodes/vanilla/dm/dm.cpp
          )
        endif()
      EOF
      expected_cmake = <<~EOF
        if(SERVER)
          set_src(GAME_SERVER GLOB_RECURSE src/game/server
            gamemodes/vanilla/dm/dm.cpp
          )
        endif()
      EOF
      patcher = CMakePatcher.new(content: input_cmake)
      expect(patcher.build_new_cmake).to eq(expected_cmake)
    end
    it 'Should add mymod.cpp' do
      input_cmake = <<~EOF
        if(SERVER)
          set_src(GAME_SERVER GLOB_RECURSE src/game/server
            gamemodes/vanilla/dm/dm.cpp
          )
        endif()
      EOF
      expected_cmake = <<~EOF
        if(SERVER)
          set_src(GAME_SERVER GLOB_RECURSE src/game/server
            gamemodes/mymod.cpp
            gamemodes/vanilla/dm/dm.cpp
          )
        endif()
      EOF
      patcher = CMakePatcher.new(content: input_cmake)
      patcher.add_file('src/game/server/gamemodes/mymod.cpp')
      expect(patcher.build_new_cmake).to eq(expected_cmake)
    end
    it 'Should write to filesystem' do
      FileUtils.mkdir_p 'spec/tmp'
      FileUtils.cp('spec/cmake/simple.cmake.in', 'spec/tmp/CMakeLists.txt')
      patcher = CMakePatcher.new(
        path: 'spec/tmp/CMakeLists.txt'
      )
      patcher.add_file('src/game/server/gamemodes/aaa.cpp')
      patcher.save
      expected_cmake = File.read('spec/cmake/simple.cmake.out')
      got_cmake = File.read('spec/tmp/CMakeLists.txt')
      FileUtils.rm_rf('spec/tmp')
      expect(expected_cmake).to eq(got_cmake)
    end
  end
end
