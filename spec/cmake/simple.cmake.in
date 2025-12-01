# This cmake file does not work and is a simple fake for tests!
# Do not use with cmake.
cmake_minimum_required(VERSION 3.12...3.27.4)

if(SERVER)
  set_src(ENGINE_SERVER_WITHOUT_MAIN GLOB_RECURSE src/engine/server
    antibot.cpp
    antibot.h
    authmanager.cpp
    upnp.cpp
    upnp.h
  )

  list(REMOVE_ITEM ENGINE_SERVER_WITHOUT_MAIN "${PROJECT_SOURCE_DIR}/src/engine/server/main.cpp")

  set_src(GAME_SERVER GLOB_RECURSE src/game/server
    ddracechat.cpp
    ddracecommands.cpp
    entities/character.cpp
    gamemodes/instagib/zcatch/colors.cpp
    gamemodes/instagib/zcatch/sql_columns.h
    gamemodes/instagib/zcatch/track_caught_time.cpp
    gamemodes/instagib/zcatch/zcatch.cpp
    gamemodes/instagib/zcatch/zcatch.h
    gamemodes/mod.cpp
    gamemodes/mod.h
    gamemodes/vanilla/base_vanilla.cpp
    gamemodes/vanilla/base_vanilla.h
    gamemodes/vanilla/ctf/ctf.cpp
    gamemodes/vanilla/ctf/ctf.h
    gamemodes/vanilla/ctf/sql_columns.h
    gamemodes/vanilla/dm/dm.cpp
    gamemodes/vanilla/dm/dm.h
    gamemodes/vanilla/dm/sql_columns.h
    gamemodes/vanilla/fly/fly.cpp
    gamemodes/vanilla/fly/fly.h
    gamemodes/vanilla/tsmash/tsmash.cpp
    gamemodes/vanilla/tsmash/tsmash.h
    gameworld.cpp
    gameworld.h
  )

  # ddnet-insta ext modes START
  file(GLOB_RECURSE EXTERNAL_GAMEMODES src/external_gamemodes/*/*.cpp src/external_gamemodes/*/*.h)
  list(APPEND GAME_SERVER ${EXTERNAL_GAMEMODES})
  # ddnet-insta ext modes END

  set(GAME_GENERATED_SERVER
    "src/generated/server_data.cpp"
    "src/generated/server_data.h"
    "src/generated/wordlist.h"
  )
endif()
