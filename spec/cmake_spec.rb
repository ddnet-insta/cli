# frozen_string_literal: true

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
      patcher.add_file("src/game/server/gamemodes/mymod.cpp")
      expect(patcher.build_new_cmake).to eq(expected_cmake)
    end
  end
end
