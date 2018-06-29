# Spec for VM <-> Elixir communication.

## Operation Listing

|message              |Arg Type |Arg Description           |Returns |
|-------------------  |---------|--------------------------|--------|
|:code_write          |string   |CeleryScript JSON         |Code ID |
|:code_rm             |int      |Code ID                   |Status  |
|:proc_kill           |int      |CS Process ID             |Status  |
|:proc_pause          |int      |CS Process ID             |Status  |
|:proc_run            |int      |CS Process ID             |Status  |
|:proc_start          |int      |Code ID                   |Pid     |
|:sys_check_updates   |none     |                          |        |
|:sys_factory_reset   |string   |package                   |        |
|:sys_power_off       |none     |                          |        |
|:sys_reboot          |none     |                          |        |
|:sys_move_absolute   |Vector3  | Needs speed?             |        |
|:sys_move_relative   |Vector3  | Just forward to Moveabs? |        |
|:sys_calibrate       |String   | Axis name                |        |
|:sys_find_home       |Vector3  | Axis Enum                |        |
|:sys_home            |Vector3  | Axis Enum                |        |
|:sys_zero            |Vector3  | Axis Enum                |        |
|:sys_set_servo_angle |int      | Angle                    |        |
|:sys_toggle_pin      |int      | Pin                      |        |
|:sys_write_pin       |int      | Pin                      |        |

### Configuration interaction and communication.
|Namespace |Operation     |Request Payload         |Return |
|----------|--------------|------------------------|-------|
|SYS       |CONFIG_UPDATE | Package, config, value |       |
|SYS       |SET_USER_ENV  | config, value          |       |
|SYS       |SEND_MESSAGE  | Message                |       |

### Farmware
|Namespace |Operation                    |Request Payload       |Return |
|----------|-----------------------------|----------------------|-------|
|SYS       |INSTALL_FIRST_PARTY_FARMWARE | NONE                 |       |
|SYS       |TAKE_PHOTO                   | NONE                 |       |
|SYS       |EXECUTE_SCRIPT               | Package (not really) |       |
|SYS       |INSTALL_FARMWARE             | Package (not really) |       |
|SYS       |REMOVE_FARMWARE              | Package (not really) |       |
|SYS       |UPDATE_FARMWARE              | Package (not really) |       |

### RPI GPIO
|Namespace |Operation       |Request Payload |Return |
|----------|----------------|----------------|-------|
|SYS       |REGISTER_GPIO   | Deprecated?    |       |
|SYS       |UNREGISTER_GPIO | Depricated?    |       |

### Control
|Namespace |Operation                  |Request Payload |Return |
|----------|---------------------------|----------------|-------|
|SYS       |WAIT (possible CPU bound?) | Milliseconds   |       |
|SYS       |SLEEP                      | WIP?           |       |
|SYS       |EXIT                       | WIP?           |       |

## Enums

Used in the request payloads of some IPC messages.

|Name   |0       |1 |2|3  |
|-------|--------|--|-|---|
|Axis   |X       |Y |Z|ALL|
|Package|Firmware|OS| |   |
w
