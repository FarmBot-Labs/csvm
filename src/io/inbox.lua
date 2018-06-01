local T = require("src/util/type_assertion")
local M = {}

-- Setup a fake inbox.
function M.setup_local_dev()
  _G.inbox = { index = 0 }
end

function M.new_message(channel, namespace, operation, payload)
  T.is_number(channel)
  T.is_string(namespace)
  T.is_string(operation)
  T.maybe_string(payload)

  return { channel   = channel,
           namespace = namespace,
           operation = operation,
           payload   = payload }
end

-- add fake inbox message
function M.push_req(namespace, operation, payload)
  T.is_string(namespace)
  T.is_string(operation)
  T.maybe_string(payload)

  local chan       = math.floor(math.random() * 100)
  local next_index = _G.inbox.index + 1

  _G.inbox.index       = next_index
  _G.inbox[next_index] = M.new_message(chan, namespace, operation, payload)
end

function M.fetch()
  local i = _G.inbox
  T.is_table(i)
  T.is_number(i.index)
  local last = i[i.index]
  T.maybe_table(last)
  if last then
    T.is_number(last.channel)
    T.is_string(last.namespace)
    T.is_string(last.operation)
    T.maybe_string(last.payload)
    i[i.index] = nil
    i.index = (i.index + 1)
  end
  return last
end

return M
