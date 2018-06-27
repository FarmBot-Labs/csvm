defmodule Csvm.InteractionHandler do
  @type return_value :: :ok | {:error, reason :: String.t }
  @doc "Requests that the host take a photo with the camera"
  @callback take_photo() :: return_value
end
