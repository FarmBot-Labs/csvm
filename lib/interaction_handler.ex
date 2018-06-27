defmodule Csvm.InteractionHandler do
  @type priv_data    :: map
  @type return_value :: {:ok, priv_data} | {:error, reason :: String.t }

  @doc "Requests that the host take a photo with the camera"
  @callback take_photo(priv_data) :: return_value
end
