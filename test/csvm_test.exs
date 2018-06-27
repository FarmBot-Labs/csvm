defmodule CsvmTest do
  use ExUnit.Case
  doctest Csvm

  setup do
    {:ok, ih  } = StubbedInteractionHandler.start_link()
    {:ok, csvm} = Csvm.start_link(StubbedInteractionHandler)

    %{csvm: csvm, interaction_handler: ih}
  end

  test "schedule", %{csvm: csvm, interaction_handler: ih} do
    huge_example = %{
      id: 123,
      kind: "sequence",
      args: %{},
      body: [
        %{ kind: "take_photo", args: %{} }
      ]
    }

    Csvm.interpret(csvm, huge_example)
    call_data = StubbedInteractionHandler.get_last_call(ih)
    assert call_data.fn_name == :take_photo
    assert call_data.fn_args == []
  end

  test "async_schedule", ctx do
  end

  test "await", ctx do
  end
end
