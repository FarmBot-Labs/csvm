defmodule CsvmTest do
  defmodule StubbedInteractionHandler do
    def take_photo do
    end
  end

  use ExUnit.Case
  doctest Csvm

  setup do
    {:ok, csvm} = Csvm.start_link(StubbedInteractionHandler)
    %{csvm: csvm}
  end

  test "schedule", %{csvm: csvm} do
    huge_example = %{
      id: 123,
      kind: "sequence",
      args: %{},
      body: [
        %{ kind: "take_photo", args: %{} }
      ]
    }

    Csvm.interpret(csvm, huge_example)
  end

  test "async_schedule", ctx do
  end

  test "await", ctx do
  end
end
