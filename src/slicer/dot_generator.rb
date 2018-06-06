HEAP = [
  {
     __next: 1,
     __parent: 1,
     __body: 1,
     __KIND: "nothing"
  },
  {
     __parent: 1,
     version: 20180209,
     __KIND: "sequence",
     __body: 3,
     __locals: 18,
     __next: 1
  },
  {
     __location: 5,
     __parent: 2,
     __offset: 4,
     __KIND: "move_absolute",
     __body: 1,
     speed: 100,
     __next: 6
  },
  {
     z: 0,
     __parent: 3,
     x: 0,
     __KIND: "coordinate",
     __body: 1,
     y: 0,
     __next: 1
  },
  {
     __parent: 3,
     pointer_type: "Plant",
     __KIND: "point",
     pointer_id: 20246,
     __body: 1,
     __next: 1
  },
  {
     z: 0,
     __parent: 3,
     x: 0,
     __KIND: "move_relative",
     speed: 100,
     __body: 1,
     y: 0,
     __next: 7
  },
  {
     pin_value: 0,
     pin_mode: 0,
     __KIND: "write_pin",
     __parent: 6,
     __body: 1,
     pin_number: 0,
     __next: 8
  },
  {
     pin_number: 0,
     __parent: 7,
     __KIND: "read_pin",
     label: "---",
     __body: 1,
     pin_mode: 0,
     __next: 9
  },
  {
     milliseconds: 0,
     __KIND: "wait",
     __body: 1,
     __parent: 8,
     __next: 10
  },
  {
     __parent: 9,
     __KIND: "send_message",
     message: "Hello, world!",
     __body: 1,
     message_type: "success",
     __next: 11
  },
  {
     __parent: 10,
     speed: 100,
     __KIND: "find_home",
     axis: "all",
     __body: 1,
     __next: 12
  },
  {
     ___then: 14,
     __KIND: "_if",
     __body: 1,
     lhs: "x",
     op: "is",
     __parent: 11,
     ___else: 13,
     __next: 15,
     rhs: 0
  },
  {
     __next: 1,
     __parent: 12,
     __body: 1,
     __KIND: "nothing"
  },
  {
     __parent: 12,
     __KIND: "execute",
     __body: 1,
     __next: 1,
     sequence_id: 1183
  },
  {
     __parent: 12,
     __KIND: "execute",
     __body: 1,
     __next: 16,
     sequence_id: 754
  },
  {
     __parent: 15,
     __KIND: "execute_script",
     label: "plant-detection",
     __body: 1,
     __next: 17
  },
  {
     __next: 1,
     __parent: 16,
     __body: 1,
     __KIND: "take_photo"
  },
  {
     __next: 1,
     __parent: 2,
     __body: 1,
     __KIND: "scope_declaration"
  }
]

puts "digraph wow {"
HEAP
  .each_with_index
  .map do |item, index|
    item.map do |(key, value)|
      lua_index = index + 1
      if key == :__KIND
        puts "  #{lua_index}      [ label = \"#{value}\" ]"
      else
        if key.to_s.include?("__") && (value != 1)
          puts "  #{lua_index} -> #{value} [ label = \"#{key.to_s.gsub("__", "")}\"]"
        end
      end
    end
  end
puts "}"
