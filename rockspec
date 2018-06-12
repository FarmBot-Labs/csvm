package = "CeleryScriptRuntime"

version = "0.0-1"

source = {
   url = "https://github.com/FarmBot-Labs/CeleryScript-Runtime"
}

description = {
   summary  = "CeleryScript Runtime Environment",
   detailed = [[
    The CeleryScript Runtime Environment executes user-defined FarmBot
    sequences. It is the underlying virtual machine and interpreter for the
    CeleryScript programming language.
   ]],
   homepage   = "https://github.com/FarmBot-Labs/CeleryScript-Runtime",
   license    = "MIT",
   maintainer = "Rick Carlino; FarmBot, Inc.",
   -- labels     = { "farmbot" }
}


dependencies = {
  "busted",
  "luacheck",
  "luacov",
  "lovebird",
  "lua >= 5.1, < 5.4",
  "penlight",
}

build = {
  type = "make"
}
