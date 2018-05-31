local inbox           = require("lua_lib/inbox")
local get_message     = inbox.fetch
local message_handler = require("lua_lib/message_handler").new()
local hypervisor      = require("lua_lib/hypervisor").new()
local main            = require("lua_lib/app")
                          .new(get_message, message_handler, hypervisor)

if (os.getenv("CELERY_ENV") == "dev") then
  inbox.setup_local_dev()
  _G.INBOX = inbox
end

while true do
  require("lovebird").update()
  main("run")
end