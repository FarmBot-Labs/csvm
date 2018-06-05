HEAP = [
    {
         :__next =>   1,
         :__KIND =>   "nothing",
         :__body =>   1,
         :__parent => 1
    },
    {
         :__KIND => "sequence",
         :__body => 3,
         :__parent => 1,
         :__locals => 18,
         :version => 20180209,
         :__next => 1
    },
    {
         :speed => 100,
         :__KIND => "move_absolute",
         :__body => 1,
         :__parent => 2,
         :__offset => 4,
         :__location => 5,
         :__next => 6
    },
    {
         :z => 0,
         :y => 0,
         :__body => 1,
         :__parent => 3,
         :__next => 1,
         :x => 0,
         :__KIND => "coordinate"
    },
    {
         :__KIND => "point",
         :__body => 1,
         :__parent => 3,
         :__next => 1,
         :pointer_type => "Plant",
         :pointer_id => 20246
    },
    {
         :z => 0,
         :y => 0,
         :__body => 1,
         :__parent => 3,
         :__next => 7,
         :speed => 100,
         :x => 0,
         :__KIND => "move_relative"
    },
    {
         :__KIND => "write_pin",
         :pin_number => 0,
         :__parent => 6,
         :__body => 1,
         :__next => 8,
         :pin_value => 0,
         :pin_mode => 0
    },
    {
         :__KIND => "read_pin",
         :pin_number => 0,
         :__parent => 7,
         :__body => 1,
         :__next => 9,
         :label => "---",
         :pin_mode => 0
    },
    {
         :__KIND => "wait",
         :__body => 1,
         :__parent => 8,
         :__next => 10,
         :milliseconds => 0
    },
    {
         :message => "FarmBot is at position {{ x }}, {{ y }}, {{ z }}.",
         :__KIND => "send_message",
         :message_type => "success",
         :__parent => 9,
         :__body => 1,
         :__next => 11
    },
    {
         :speed => 100,
         :__KIND => "find_home",
         :__body => 1,
         :__parent => 10,
         :axis => "all",
         :__next => 12
    },
    {
         :__body => 1,
         :lhs => "x",
         :__KIND => "_if",
         :__next => 15,
         :__parent => 11,
         :rhs => 0,
         :___then => 13,
         :op => "is",
         :___else => 14
    },
    {
         :__next => 1,
         :__KIND => "nothing",
         :__body => 1,
         :__parent => 12
    },
    {
         :__next => 1,
         :__KIND => "nothing",
         :__body => 1,
         :__parent => 12
    },
    {
         :sequence_id => 754,
         :__next => 16,
         :__body => 1,
         :__parent => 12,
         :__KIND => "execute"
    },
    {
         :__KIND => "execute_script",
         :label => "plant-detection",
         :__parent => 15,
         :__body => 1,
         :__next => 17
    },
    {
         :__next => 1,
         :__KIND => "take_photo",
         :__body => 1,
         :__parent => 16
    },
    {
         :__next => 1,
         :__KIND => "scope_declaration",
         :__body => 1,
         :__parent => 2
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
