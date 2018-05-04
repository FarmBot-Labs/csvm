# Request Header (16 bytes)

Requests can travel in either direction:

```

HOST ---> REQUEST VM
```
|Seg|Description |Width   |Notes                   |
|---|------------|--------|------------------------|
| 0 |Request ID  | 2 bytes| Uint16, not ASCII      |
| 1 |Namespace   | 4 bytes| Underscore padded ASCII|
| 2 |Command     | 6 bytes| Underscore padded ASCII|
| 3 |Payload size| 2 bytes| Uint16                 |
| 4 |CLRF        | 2 bytes| Y'know, `\r\n`         |

Followed by a "payload"

# Request Payload

This is based on the size of segment 3 in the header and is typically used for
paramter storage.

# Response (6 bytes)

|Seg|Description           |Width   |Notes                                          |
|---|----------------------|--------|-----------------------------------------------|
|  0|Initiator's Request ID| 2 bytes| Unique request identifier. Requestor's choice.|
|  1|Return value          | 2 bytes| Uint16                                        |
|  2|CLRF                  | 2 bytes|                                               |

# IPC Listing

|Namespace|Command|Request Payload                                   |Return |
|---------|-------|--------------------------------------------------|-------|
|SLICE    |NEW    |Still up for discussion.                          |       |
|REGISTER |NEW    |Still up for discussion.                          |       |
|CODE     |CREATE |None                                              |Code ID|
|CODE     |OPEN   |Code ID                                           |Status |
|CODE     |WRITE  |CeleryScript JSON                                 |Status |
|CODE     |CLOSE  |Code ID                                           |Status |
|CODE     |RM     |Code ID                                           |Status |
|PROC     |START  |Code ID                                           |Pid    |
|PROC     |PAUSE  |Process ID                                        |Status |
|PROC     |KILL   |Process ID                                        |Status |
|PROC     |RUN    |Process ID                                        |Status |

# Hypervisor Calls

|Namespace |Command                      |Request Payload                                   |Return |
|----------|-----------------------------|--------------------------------------------------|-------|
|SYS       |CHECK_UPDATES                |                                                  |       |
|SYS       |POWER_OFF                    |                                                  |       |
|SYS       |TAKE_PHOTO                   |                                                  |       |
|SYS       |FACTORY_RESET                | Package                                          |       |
|SYS       |CALIBRATE                    | Axis Enum                                        |       |
|SYS       |FIND_HOME                    |                                                  |       |
|SYS       |CONFIG_UPDATE                |                                                  |       |
|SYS       |EXECUTE_SCRIPT               |                                                  |       |
|SYS       |HOME                         |                                                  |       |
|SYS       |INSTALL_FARMWARE             |                                                  |       |
|SYS       |INSTALL_FIRST_PARTY_FARMWARE |                                                  |       |
|SYS       |MOVE_ABSOLUTE                |                                                  |       |
|SYS       |MOVE_RELATIVE                |                                                  |       |
|SYS       |REGISTER_GPIO                |                                                  |       |
|SYS       |REMOVE_FARMWARE              |                                                  |       |
|SYS       |SEND_MESSAGE                 |                                                  |       |
|SYS       |SET_SERVO_ANGLE              |                                                  |       |
|SYS       |SET_USER_ENV                 |                                                  |       |
|SYS       |TOGGLE_PIN                   |                                                  |       |
|SYS       |UNREGISTER_GPIO              |                                                  |       |
|SYS       |UPDATE_FARMWARE              |                                                  |       |
|SYS       |WAIT                         |                                                  |       |
|SYS       |WRITE_PIN                    |                                                  |       |
|SYS       |ZERO                         |                                                  |       |
|SYS       |SLEEP                        |WIP?                                              |       |
|SYS       |EXIT                         |WIP?                                              |       |

# Enums

Used in the request payloads of some IPC messages.

|Name   |0       |1 |2|3  |
|-------|--------|--|-|---|
|Axis   |X       |Y |Z|ALL|
|Package|Firmware|OS| |   |

# Instruction Set Notes

## CPU Bound
  :_else
  :_if
  :_then
  :axis
  :channel
  :channel_name
  :coordinate
  :data_type
  :data_value
  :explanation
  :identifier
  :label
  :lhs
  :locals
  :location
  :message
  :message_type
  :milliseconds
  :named_pin
  :nothing
  :offset
  :op
  :package
  :pair
  :parameter_declaration
  :pin_id
  :pin_mode
  :pin_number
  :pin_type
  :pin_value
  :point
  :pointer_id
  :pointer_type
  :radius
  :read_pin
  :rhs
  :rpc_error
  :rpc_ok
  :scope_declaration
  :sequence_id
  :speed
  :tool
  :tool_id
  :url
  :value
  :variable_declaration
  :version
  :x
  :y
  :z

## I/O Bound
  :calibrate
  :change_ownership
  :check_updates
  :config_update
  :execute_script
  :factory_reset
  :find_home
  :home
  :install_farmware
  :install_first_party_farmware
  :move_absolute
  :move_relative
  :package
  :power_off
  :register_gpio
  :remove_farmware
  :send_message
  :set_servo_angle
  :set_user_env
  :take_photo
  :toggle_pin
  :unregister_gpio
  :update_farmware
  :wait
  :write_pin
  :zero

## Too Soon To Say
  :execute
  :read_status
  :reboot
  :rpc_request
  :sequence
  :sync
  :emergency_lock
  :emergency_unlock
