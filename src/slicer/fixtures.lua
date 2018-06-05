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

return M
