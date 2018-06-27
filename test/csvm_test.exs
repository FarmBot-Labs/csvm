defmodule CsvmTest do
  use ExUnit.Case
  doctest Csvm

  setup do
    {:ok, ih} = StubbedInteractionHandler.start_link()
    csvm = Csvm.new(StubbedInteractionHandler)
    Csvm.asign(csvm, %{interaction_handler: ih})
    %{csvm: csvm, interaction_handler: ih}
  end

  # test "one tick", %{csvm: csvm, interaction_handler: ih} do
  #   huge_example = %{
  #     id: 123,
  #     kind: "sequence",
  #     args: %{},
  #     body: [
  #       %{kind: "take_photo", args: %{}}
  #     ]
  #   }
  #
  #   new_vm = Csvm.tick(csvm, huge_example)
  #   assert Csvm.get_pc(new_vm) == 1
  #   call_data = StubbedInteractionHandler.get_last_call(ih)
  #   assert call_data.fn_name == :take_photo
  #   assert call_data.fn_args == []
  # end
end
