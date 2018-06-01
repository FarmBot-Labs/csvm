local inbox           = require("src/io/inbox")
local get_message     = inbox.fetch
local vm              = require("src/vm").new()
local main            = require("src/app").new(get_message, vm)

if (os.getenv("CELERY_ENV") == "dev") then
  inbox.setup_local_dev()
  _G.INBOX = inbox
end

while true do
  require("lib/lovebird").update()
  main("run")
end
