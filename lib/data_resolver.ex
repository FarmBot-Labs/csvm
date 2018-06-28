defmodule Csvm.DataResolver do
# MOVE_REL WILL NEED:
# * {x, y, z}

# LOCATION WILL DEAL WITH:
# * :tool       (MUST be handled by host)
# * :point      (can be handled by host)
#   { point_id: 123}
# * :coordinate (MUST be handled by host)
#   { x, y, z}
# * :identifier (cant be dealt with by host)
#   it depends

  def resolve(heap, pointer, field) do
  end
end
