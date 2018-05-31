#!/bin/sh
luacheck --std max+busted lua_lib/*.lua
busted .
