defmodule Flamelex.Fluxus.Reducers.Buffer do
  use Flamelex.Fluxux.ReducerBehaviour


  def async_reduce(radix_state, {:open_buffer, opts}) do
    buf = Flamelex.Buffer.open!(opts)
    GenServer.cast(Flamelex.FluxusRadix,
                   {:radix_state_update,
                     radix_state |> RadixState.set_active_buffer(buf)})

  end


  def async_reduce(_radix_state,
        {:move_cursor, %{
            buffer:   %{type: Flamelex.Buffer.Text} = text_buf_ref,
            details:  details}}
  ) do

    # {:gui_component, {:text_cursor, buffer_ref, 1}} #TODO properly define this wannabee tree structure

    # {:gui_component, buf_ref.ref} # find the Flamelex.GUI.Component.TextBox process for this Buffer.Text

    text_buf_ref
    |> ProcessRegistry.find!()
    |> GenServer.cast({:move_cursor, details}) #TODO cursor number??
  end


  def async_reduce(_radix_state, _a) do
    :ignoring_action
  end
end
