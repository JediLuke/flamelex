defmodule Flamelex.Fluxus.Reducers.Buffer do
  use Flamelex.Fluxux.ReducerBehaviour


  def async_reduce(radix_state, {:open_buffer, opts}) do

    buf =
      Flamelex.Buffer.open!(opts)
    radix_update =
      {:radix_state_update, radix_state |> RadixState.set_active_buffer(buf)}

    GenServer.cast(Flamelex.FluxusRadix, radix_update)
  end


  def async_reduce(_radix_state, {:move_cursor, %{buffer: buffer_tag, details: details}}) do
    buffer_tag
    |> ProcessRegistry.find!()
    |> GenServer.cast({:move_cursor, details})
  end


  def async_reduce(_radix_state, _a) do
    :ignoring_action
  end
end
