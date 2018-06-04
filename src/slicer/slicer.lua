local T      = require("src/util/type_assertion")
local CSHeap = require("src/slicer/heap")
local M      = {}

function M.new ()
  local this = {}

  this.run = function(node)
    T.is_table(node)
    this.root_node     = node
    local heap = CSHeap.new()
    this.allocate(heap, node, CSHeap.NULL)
    heap = heap.entries
    heap:map(function (x)
      if not x[CSHeap.BODY] then
        x[CSHeap.BODY] = CSHeap.NULL
      end
      if not x[CSHeap.NEXT] then
        x[CSHeap.NEXT] = CSHeap.NULL
      end
    end)
    return heap.entries
  end

  this.recurse_into_body =
    function(heap, canonical_list, previous_address, i)
      local index = i or 0
      if canonical_list[index] then
        local is_head = index == 0
        if is_head then
          -- BE CAREFUL EDITING THIS LINE, YOU MIGHT BREAK `BODY` NODES:
          heap.put(previous_address,
                   CSHeap.BODY,
                   previous_address + 1) -- See note above!
        end

        local my_heap_address = this.allocate(heap,
                                              canonical_list[index],
                                              previous_address)
        if is_head then
          heap.put(previous_address, CSHeap.NEXT, CSHeap.NULL)
        else
          heap.put(previous_address, CSHeap.NEXT, my_heap_address)
        end

        this.recurse_into_body(heap, canonical_list, my_heap_address, index + 1)
      end
    end

  this.is_celery_script = function(node)
    return (type(node) == "table") and (node.args) and (node.kind)
  end

  this.iterate_over_body = function(heap, canonical_node, parentAddr)
    local body = (canonical_node.body or {})
    this.recurse_into_body(heap, body, parentAddr)
  end

  this.iterate_over_args = function(h, s, parentAddr)
    local tbl = s.args or {}
    for key, _ in pairs(tbl) do
      local v = s.args[key]
      if this.is_celery_script(v) then
        local k = CSHeap.LINK + key.to_s
        h.put(parentAddr, k, this.allocate(h, v, parentAddr))
      else
        h.put(parentAddr, key, v)
      end
    end
   end

  this.allocate = function (h, s, parentAddr)
    local addr = h.allot(s.kind)
    h.put(addr, CSHeap.PARENT, parentAddr)
    if s.comment then
      h.put(addr, CSHeap.COMMENT, s.comment)
    end
    this.iterate_over_body(h, s, addr)
    this.iterate_over_args(h, s, addr)
    return addr
  end

  return this
end

return M
