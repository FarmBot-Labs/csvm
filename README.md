# Csvm

A virtual machine for CeleryScript.

## Configuration

```elixir
config(:csvm, foo: "BAR")
```

```elixir

# See note below about syscall_handler_pid
# TODO: Define behavior.
{:ok, csvm_pid} = Csvm.start_link(handlers) # See VM -> Host notes

```

# VM -> Host Communication (Handler)

Examples:

 * Requesting the coordinates of point 34234234
 * Move the gantry to (4,5,6)

|message         | Expected Return |Description                                 |
|----------------|-----------------|--------------------------------------------|
|:sys_move_abs   |:ok              |Requests movement to a point and then pauses|

1. You "send" the :sys_move_abs with (0,0,2)
2. Host responds to request.
3. Some time passes.
4. Request completion is sent separately.

# Host -> VM Communication

Examples:

 * Telling the VM to step
 * Adding code to the list of things that can run.

The host may send the VM messages via genserver calls.

|message       |Returns        |Description                   |
|--------------|---------------|------------------------------|
|:sys_tick/0   |:ok            |Continue operations           |
|:code_write/1 |{:ok, code_id} |Register celeryscript with VM |

## Installation

```elixir
def deps do
  [
    {:csvm, "~> 0.0.1"}
  ]
end
```
