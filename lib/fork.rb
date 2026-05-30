# frozen_string_literal: true

class Fork
  def initialize(name)
    @name = name
  end

  def create
    patch_cmake
    create_cmake
    create_source_files
    register_includes
  end

  private

  def register_includes
    patch_include('src/insta/includes/chat_commands.h', "#include <src/#{@name}/server/chat_commands.h>")
    patch_include('src/insta/includes/rcon_commands.h', "#include <src/#{@name}/server/rcon_commands.h>")
    patch_include('src/insta/includes/engine/shared/config_variables.h',
                  "#include <src/#{@name}/engine/shared/config_variables_#{@name}.h>")
  end

  def patch_include(path, line)
    puts "[*] adding fork include to #{path.green}"
    file = File.open(path, 'a')
    file.write("\n#{line}\n")
    file.close
  end

  def create_source_files
    create_chat_commands_cpp
    create_chat_commands_h
    create_rcon_commands_cpp
    create_rcon_commands_h
    create_version_h
    create_variables_h
  end

  def create_chat_commands_cpp
    code = <<~CODE_EOF
      #include <base/str.h>
      #include <base/time.h>

      #include <engine/shared/config.h>
      #include <engine/shared/protocol.h>

      #include <generated/protocol.h>

      #include <game/server/entities/character.h>
      #include <game/server/gamecontext.h>
      #include <game/server/gamecontroller.h>
      #include <game/server/player.h>
      #include <game/server/score.h>

      #include <insta/server/enums.h>

      /*
      void CGameContext::ConInstaModeCredits(IConsole::IResult *pResult, void *pUserData)
      {
             CGameContext *pSelf = (CGameContext *)pUserData;
             if(pSelf->m_pController)
                     pSelf->m_pController->OnCreditsChatCmd(pResult, pUserData);
      }
      */
    CODE_EOF
    add_file("src/#{@name}/server/chat_commands.cpp", code)
  end

  def create_chat_commands_h
    code = <<~CODE_EOF
      // This file can be included several times.

      #ifndef CHAT_COMMAND
      #error "The config macros must be defined"
      // This helps IDEs properly syntax highlight the uses of the macro below.
      #define CHAT_COMMAND(name, params, flags, callback, userdata, help) ;
      #endif

      // CHAT_COMMAND("credits", "", CFGFLAG_CHAT | CFGFLAG_SERVER, ConInstaModeCredits, this, "Shows the credits of the current ddnet-insta mode");
    CODE_EOF
    add_file("src/#{@name}/server/chat_commands.h", code)
  end

  def create_rcon_commands_cpp
    code = <<~CODE_EOF
      #include <base/log.h>
      #include <base/net.h>
      #include <base/types.h>
      #include <base/vmath.h>

      #include <engine/antibot.h>
      #include <engine/shared/config.h>
      #include <engine/shared/protocol.h>

      #include <generated/protocol.h>

      #include <game/server/entities/character.h>
      #include <game/server/gamecontext.h>
      #include <game/server/gamecontroller.h>
      #include <game/server/player.h>

      #include <insta/server/ip_storage.h>

      /*
      void CGameContext::ConHammer(IConsole::IResult *pResult, void *pUserData)
      {
             CGameContext *pSelf = (CGameContext *)pUserData;
             pSelf->ModifyWeapons(pResult, pUserData, WEAPON_HAMMER, false);
      }
      */
    CODE_EOF
    add_file("src/#{@name}/server/rcon_commands.cpp", code)
  end

  def create_rcon_commands_h
    code = <<~CODE_EOF
      // This file can be included several times.
      // doc gen ignore: pause_game, restart

      #ifndef CONSOLE_COMMAND
      #error "The config macros must be defined"
      // This helps IDEs properly syntax highlight the uses of the macro below.
      #define CONSOLE_COMMAND(name, params, flags, callback, userdata, help) ;
      #endif

      // CONSOLE_COMMAND("pause_game", "", CFGFLAG_SERVER, ConInstaPause, this, "Pause/unpause game");
    CODE_EOF
    add_file("src/#{@name}/server/rcon_commands.h", code)
  end

  def create_version_h
    code = <<~CODE_EOF
      #ifndef #{@name.upcase}_SERVER_VERSION_H
      #define #{@name.upcase}_SERVER_VERSION_H

      #define #{@name.upcase}_VERSIONSTR "v0.0.1"
      #define #{@name.upcase}_BUILD_DATE __DATE__ ", " __TIME__

      #endif
    CODE_EOF
    add_file("src/#{@name}/server/version.h", code)
  end

  def create_variables_h
    code = <<~CODE_EOF
      // This file can be included several times.

      #ifndef MACRO_CONFIG_INT
      #error "The config macros must be defined"
      // This helps IDEs properly syntax highlight the uses of the macro below.
      #define MACRO_CONFIG_INT(Name, ScriptName, Def, Min, Max, Save, Desc) ;
      #define MACRO_CONFIG_COL(Name, ScriptName, Def, Save, Desc) ;
      #define MACRO_CONFIG_STR(Name, ScriptName, Len, Def, Save, Desc) ;
      #endif

      MACRO_CONFIG_INT(SvPlaceholder, sv_placeholder, 0, 0, 1, CFGFLAG_SAVE | CFGFLAG_SERVER, "placeholder")
    CODE_EOF
    add_file("src/#{@name}/engine/shared/config_variables_#{@name}.h", code)
  end

  def add_file(path, content)
    FileUtils.mkdir_p File.dirname(path)
    File.write(path, content)
    puts "[*] created file #{path.green}"
  end

  def patch_cmake
    puts "[*] adding fork to #{'CMakeLists.txt'.green}"
    cmake = CMakePatcher.new(path: 'CMakeLists.txt')
    cmake.add_fork(@name)
    cmake.save
  end

  def create_cmake
    FileUtils.mkdir_p "src/#{@name}"
    cmake_path = "src/#{@name}/CMakeLists.txt"
    File.write(cmake_path, cmake_content)
    puts "[*] created file #{cmake_path.green}"
  end

  def cmake_content
    <<~CMAKE_EOF
      function(#{@name}_patch_engine)
          set_src(INSTA_ENGINE_SHARED GLOB_RECURSE src/#{@name}/engine/shared
            config_variables_#{@name}.h
          )

          set(ENGINE_SHARED ${ENGINE_SHARED} PARENT_SCOPE)
          list(APPEND ENGINE_SHARED ${INSTA_INCLUDES} ${INSTA_ENGINE_SHARED})
          set(ENGINE_SHARED ${ENGINE_SHARED} PARENT_SCOPE)
      endfunction()

      function(#{@name}_patch_server)
          set_src(INSTA_SERVER GLOB_RECURSE src/#{@name}/server
            chat_commands.cpp
            chat_commands.h
            rcon_commands.cpp
            rcon_commands.h
            version.h
          )

          set(GAME_SERVER ${GAME_SERVER} PARENT_SCOPE)
          list(APPEND GAME_SERVER ${INSTA_EXTERNAL_GAMEMODES} ${INSTA_SERVER})
          set(GAME_SERVER ${GAME_SERVER} PARENT_SCOPE)
      endfunction()
    CMAKE_EOF
  end
end
