defmodule Csvm.AST do
  @moduledoc """
  Handy functions for turning various data types into Farbot Celery Script
  Ast nodes.
  """

  @typedoc "Arguments to a Node."
  @type args :: map

  @typedoc "Body of a Node."
  @type body :: [t]

  @typedoc "Kind of a Node."
  @type kind :: module

  @typedoc "AST node."
  @type t :: %__MODULE__{
          kind: kind,
          args: args,
          body: body,
          comment: binary
        }

  defstruct [:args, :body, :kind, :comment]

  def parse(map_or_json_map)

  def parse(%{__struct__: _} = thing) do
    thing |> Map.from_struct() |> parse
  end

  def parse(%{"kind" => kind, "args" => args} = thing) do
    body = thing["body"] || []
    comment = thing["comment"]

    %__MODULE__{
      kind: String.to_atom(to_string(kind)),
      args: parse_args(args),
      body: parse(body),
      comment: comment
    }
  end

  def parse(%{kind: kind, args: args} = thing) do
    body = thing[:body] || []
    comment = thing[:comment]
    %__MODULE__{kind: kind, body: parse(body), args: parse_args(args), comment: comment}
  end

  # You can give a list of nodes.
  def parse(body) when is_list(body) do
    Enum.reduce(body, [], fn blah, acc ->
      acc ++ [parse(blah)]
    end)
  end

  def parse(other_thing), do: {:error, "#{inspect(other_thing)} is not valid celeryscript"}

  def parse_args(map) when is_map(map) do
    Enum.reduce(map, %{}, fn {key, val}, acc ->
      if is_map(val) do
        # if it is a map, it could be another node so parse it too.
        real_val = parse(val)
        Map.put(acc, String.to_atom(key), real_val)
      else
        Map.put(acc, String.to_atom(key), val)
      end
    end)
  end

  def new(kind, args, body) when is_map(args) and is_list(body) do
    %__MODULE__{kind: String.to_atom(to_string(kind)), args: args, body: body}
  end
end
