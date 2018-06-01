local inbox      = require("src/io/inbox")
local hypervisor = require("src/hypervisor").new()
local app        = require("src/app")

if (os.getenv("CELERY_ENV") == "dev") then
  inbox.setup_local_dev()
  _G.INBOX = inbox -- Easy to access from `lovebird`.
end

while true do
  require("lib/lovebird").update()
  app.run(inbox.fetch, hypervisor)
end
