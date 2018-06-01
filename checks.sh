#!/bin/sh
luacheck --std max+busted src/*.lua
busted .
