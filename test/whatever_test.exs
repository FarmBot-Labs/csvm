defmodule WhateverTest do
  use ExUnit.Case
  doctest Whatever

  test "greets the world" do
    assert Whatever.hello() == :world
  end
end
