local inbox      = require("src/io/inbox")
local reply      = require("src/io/outbox").reply
local hypervisor = require("src/hypervisor").new(reply)
local app        = require("src/app")

if (os.getenv("CELERY_ENV") == "dev") then
  inbox.setup_local_dev() -- Easy to access from `lovebird`.
  _G.INBOX = inbox
end

while true do
  if (os.getenv("CELERY_ENV") == "dev") then
    require("lib/lovebird").update()
  end

  app.run(inbox.fetch, hypervisor)
end
