local inbox      = require("src/io/inbox")
local reply      = require("src/io/outbox").reply
local hypervisor = require("src/hypervisor").new(reply)
local app        = require("src/app")
X                = require("src/slicer/heap").new()

if (os.getenv("CELERY_ENV") == "dev") then
  inbox.setup_local_dev()
  _G.INBOX = inbox -- Easy to access from `lovebird`.
end

while true do
  require("lib/lovebird").update()
  app.run(inbox.fetch, hypervisor)
end
