local input_queue     = InputQueue()
local message_handler = MessageHandler()
local hypervisor      = Hypervisor()
local main            = App(input_queue, message_handler, hypervisor)

main("run")
