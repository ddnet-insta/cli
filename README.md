# cli

A command line tool written in ruby.
That is supposed to help with boiler plate code in the [ddnet-insta](https://github.com/ddnet-insta/ddnet-insta) project.


This tool is heavily inspired by the [rails](https://github.com/rails/rails) cli.

## example usage

Go to your [ddnet-insta](https://github.com/ddnet-insta/ddnet-insta) source code and run the following command:

```
./scripts/cli battle_gores:base_pvp
```

This will create the following output

```
[*] created file src/game/server/gamemodes/battle_gores/battle_gores.h
[*] created file src/game/server/gamemodes/battle_gores/battle_gores.cpp
[*] adding files to CMakeLists.txt
```

The string `battle_gores` is the new gamemode name you can choose freely.
And `base_pvp` is the parent controller you inherit from. You can also use `insta_core`
instead. If you provide no arguments at all the cli tool is fully interactive
and will ask you for all the values it needs.
