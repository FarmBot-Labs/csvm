local M = {}
M.example1 =
  [[
    {
        "id": 2126,
        "created_at": "2018-05-03T20:03:16.947Z",
        "updated_at": "2018-06-05T18:55:19.893Z",
        "args": {
            "version": 20180209,
            "locals": {
                "kind": "scope_declaration",
                "args": {}
            }
        },
        "color": "gray",
        "name": "Deleteme",
        "kind": "sequence",
        "body": [
            {
                "kind": "move_absolute",
                "args": {
                    "speed": 100,
                    "offset": {
                        "kind": "coordinate",
                        "args": {
                            "z": 0,
                            "y": 0,
                            "x": 0
                        }
                    },
                    "location": {
                        "kind": "point",
                        "args": {
                            "pointer_id": 20246,
                            "pointer_type": "Plant"
                        }
                    }
                }
            },
            {
                "kind": "move_relative",
                "args": {
                    "speed": 100,
                    "z": 0,
                    "y": 0,
                    "x": 0
                }
            },
            {
                "kind": "write_pin",
                "args": {
                    "pin_mode": 0,
                    "pin_value": 0,
                    "pin_number": 0
                }
            },
            {
                "kind": "read_pin",
                "args": {
                    "label": "---",
                    "pin_mode": 0,
                    "pin_number": 0
                }
            },
            {
                "kind": "wait",
                "args": {
                    "milliseconds": 0
                }
            },
            {
                "kind": "send_message",
                "args": {
                    "message_type": "success",
                    "message": "FarmBot is at position {{ x }}, {{ y }}, {{ z }}."
                }
            },
            {
                "kind": "find_home",
                "args": {
                    "speed": 100,
                    "axis": "all"
                }
            },
            {
                "kind": "_if",
                "args": {
                    "rhs": 0,
                    "op": "is",
                    "lhs": "x",
                    "_else": {
                        "kind": "nothing",
                        "args": {}
                    },
                    "_then": {
                        "kind": "execute",
                        "args": {
                            "sequence_id": 1183
                        }
                    }
                }
            },
            {
                "kind": "execute",
                "args": {
                    "sequence_id": 754
                }
            },
            {
                "kind": "execute_script",
                "args": {
                    "label": "plant-detection"
                }
            },
            {
                "kind": "take_photo",
                "args": {}
            }
        ],
        "in_use": false
    }
]]

M.sliced_example1 = {
  { -- 1
    __next = 1,
    __parent = 1,
    __body = 1,
    __KIND = "nothing"
  },
  { -- 2
    __KIND = "sequence",
    __parent = 1,
    __body = 3,
    __locals = 18,
    __next = 1,
    version = 20180209
  },
  { -- 3
    __KIND = "move_absolute",
    __location = 5,
    __parent = 2,
    __offset = 4,
    __body = 1,
    speed = 100,
    __next = 6
  },
  { -- 4
    __KIND = "coordinate",
    __next = 1,
    __parent = 3,
    __body = 1,
    x = 0,
    y = 0,
    z = 0
  },
  { -- 5
    __KIND = "point",
    __parent = 3,
    __body = 1,
    __next = 1,
    pointer_type = "Plant",
    pointer_id = 20246
  },
  { -- 6
    __KIND = "move_relative",
    __body = 1,
    __next = 7,
    __parent = 3,
    speed = 100,
    x = 0,
    y = 0,
    z = 0
  },
  { -- 7
    __KIND = "write_pin",
    __body = 1,
    __next = 8,
    __parent = 6,
    pin_mode = 0,
    pin_number = 0,
    pin_value = 0
  },
  { -- 8
    __KIND = "read_pin",
    __body = 1,
    __next = 9,
    __parent = 7,
    label = "---",
    pin_mode = 0,
    pin_number = 0,
  },
  { -- 9
    milliseconds = 0,
    __KIND = "wait",
    __body = 1,
    __parent = 8,
    __next = 10
  },
  { -- 10
    __parent = 9,
    __KIND = "send_message",
    __body = 1,
    __next = 11,
    message = "Hello, world!",
    message_type = "success",
  },
  { -- 11
    __parent = 10,
    speed = 100,
    __KIND = "find_home",
    axis = "all",
    __body = 1,
    __next = 12
  },
  { -- 12
    ___then = 14,
    __KIND = "_if",
    __body = 1,
    lhs = "x",
    op = "is",
    __parent = 11,
    ___else = 13,
    __next = 15,
    rhs = 0
  },
  { -- 13
    __next = 1,
    __parent = 12,
    __body = 1,
    __KIND = "nothing"
  },
  { -- 14
    __parent = 12,
    __KIND = "execute",
    __body = 1,
    __next = 1,
    sequence_id = 1183
  },
  { -- 15
    __parent = 12,
    __KIND = "execute",
    __body = 1,
    __next = 16,
    sequence_id = 754
  },
  { -- 16
    __parent = 15,
    __KIND = "execute_script",
    label = "plant-detection",
    __body = 1,
    __next = 17
  },
  { -- 17
    __next = 1,
    __parent = 16,
    __body = 1,
    __KIND = "take_photo"
  },
  { -- 18
    __next = 1,
    __parent = 2,
    __body = 1,
    __KIND = "scope_declaration"
  }
}
return M
