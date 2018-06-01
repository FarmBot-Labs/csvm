local inbox = require "src/io/inbox"

describe("inbox.fetch()", function()
  it("grabs the last item", function()
    local expected = { channel   = 5,
                       namespace = "NS",
                       operation = "OP",
                       payload   = "payload" }
    _G.inbox = { index = 1, [1] = expected }

    local result = inbox.fetch()
    assert.are.same(result, expected)
  end)

  it("returns nil", function()
    local expected = nil
    _G.inbox = { index = 1, [1] = nil }
    local result = inbox.fetch()
    assert.are.same(result, expected)
  end)

  it("Works down the queue, one  item at a time", function ()
    local expected = {
      {
        channel   = 4,
        namespace = "FOUR",
        operation = "CD",
        payload   = nil
      }, {
        channel   = 5,
        namespace = "FIVE",
        operation = "OP",
        payload   = "payload"
      }, {
        channel   = 6,
        namespace = "SIX_",
        operation = "GH",
        payload   = "payload"
      },
    }

    _G.inbox = {
      index = 1,
      [1]   = expected[1],
      [2]   = expected[2],
      [3]   = expected[3]
    }

    assert.is_truthy(_G.inbox[1])
    assert.is_truthy(_G.inbox[2])
    assert.is_truthy(_G.inbox[3])

    assert.are.same(inbox.fetch(), expected[1])
    assert.are.same(inbox.fetch(), expected[2])
    assert.are.same(inbox.fetch(), expected[3])

    assert.is_nil(_G.inbox[1])
    assert.is_nil(_G.inbox[2])
    assert.is_nil(_G.inbox[3])
  end)

  it("resets the inbox", function ()
    inbox.setup_local_dev()
    assert.are.same(_G.inbox.index, 0)
  end)

  it("Pushes a request into the inbox", function ()
    inbox.setup_local_dev()
    inbox.push_req("FOO", "BAR", "BAZ")
    local msg = inbox.fetch()
    assert.are.same(type(msg.channel), "number")
    assert.are.same(msg.namespace,     "FOO")
    assert.are.same(msg.operation,     "BAR")
    assert.are.same(msg.payload,       "BAZ")
  end)
end
)
