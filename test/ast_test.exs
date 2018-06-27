defmodule Csvm.ASTTest do
  use ExUnit.Case, async: true
  alias Csvm.AST

  @nothing_json "{\"kind\": \"nothing\", \"args\": {}}" |> Jason.decode!()
  @nothing_json_with_body "{\"kind\": \"nothing\", \"args\": {}, \"body\":[#{
                            Jason.encode!(@nothing_json)
                          }]}"
                          |> Jason.decode!()
  @bad_json "{\"whoops\": "

  test "parses ast from json" do
    res = AST.parse(@nothing_json)
    assert match?(%AST{}, res)
  end

  test "won't parse ast from bad json" do
    res = AST.parse(@bad_json)
    assert match?({:error, _}, res)
  end

  test "parses ast with sub asts in the body" do
    res = AST.parse(@nothing_json_with_body)
    assert match?(%AST{}, res)
  end
end
