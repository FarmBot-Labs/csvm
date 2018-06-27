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

  # AST struct.
  defstruct [:kind, :args, :body, :comment]
end
