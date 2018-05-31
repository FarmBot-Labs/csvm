local get_message     = require("lua_lib/inbox").fetch
local message_handler = MessageHandler()
local hypervisor      = Hypervisor()
local main            = App(get_message, message_handler, hypervisor)

main("run")
