local T      = require("src/util/type_assertion")
local CSHeap = require("src/slicer/heap")
local M      = {}

function M.new ()
  local this = {}
  this.run = function(node)
    T.is_table(node)
    this.nesting_level = 0
    this.root_node     = node
    local heap = CSHeap.new()
    this.allocate(heap, node, CSHeap.NULL)
    this.heap_values = heap.values()
    this.heap_values.map(function (x)
      if not x[CSHeap.BODY] then
        x[CSHeap.BODY] = CSHeap.NULL
      end
      if not x[CSHeap.NEXT] then
        x[CSHeap.NEXT] = CSHeap.NULL
      end
    end)
    heap.entries()
  end

  --   attr_reader :root_node
  return this
end

return M
--   class Slicer

--   def is_celery_script(node)
--     node && node.is_a?(Hash) && node[:args] && node[:kind]
--   end

--   def heap_values
--     this.heap_values
--   end

--   def allocate(h, s, parentAddr)
--     addr = h.allot(s[:kind])
--     h.put(addr, CSHeap.PARENT, parentAddr)
--     h.put(addr, CSHeap.COMMENT, s[:comment]) if s[:comment]
--     iterate_over_body(h, s, addr)
--     iterate_over_args(h, s, addr)
--     addr
--   end

--   def iterate_over_args(h, s, parentAddr)
--     (s[:args] || {})
--     .keys
--     .map do |key|
--       v = s[:args][key]
--       if (is_celery_script(v))
--       k = CSHeap.LINK + key.to_s
--       h.put(parentAddr, k, allocate(h, v, parentAddr))
--       else
--       h.put(parentAddr, key, v)
--       end
--     end
--   end

--   def iterate_over_body(heap, canonical_node, parentAddr)
--     body = (canonical_node[:body] || []).map(&:deep_symbolize_keys)
--     # !body.none? && heap.put(parentAddr, CSHeap.BODY, parentAddr + 1)
--     this.nesting_level += 1
--     recurse_into_body(heap, body, parentAddr)
--     this.nesting_level -= 1
--   end

--   def recurse_into_body(heap, canonical_list, previous_address, index = 0)
--     if canonical_list[index]
--     is_head     = index == 0
--     # BE CAREFUL EDITING THIS LINE, YOU MIGHT BREAK `BODY` NODES:
--     heap # See note above!
--       .put(previous_address, CSHeap.BODY, previous_address + 1) if is_head

--     my_heap_address = allocate(heap, canonical_list[index], previous_address)

--     prev_next_key = is_head ? CSHeap.NULL : my_heap_address
--     heap.put(previous_address, CSHeap.NEXT, prev_next_key)

--     recurse_into_body(heap, canonical_list, my_heap_address, index + 1)
--     end
--   end
--   end
-- end
