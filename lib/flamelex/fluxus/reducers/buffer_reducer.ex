defmodule Flamelex.Fluxus.Reducers.Buffer do
  use Flamelex.Fluxux.ReducerBehaviour
  alias Flamelex.Buffer.BufUtils
  alias Flamelex.Structs.BufRef


  def async_reduce(radix_state,
    {:open_buffer, {:local_text_file, path: filepath}, opts}
  ) when is_map(opts) do

    opts = Map.merge(opts, %{
      type: Flamelex.Buffer.Text, #TODO yuck
      from_file: filepath,
      open_in_gui?: true, #TODO remove
    })

    buf = Flamelex.Buffer.open!(opts)

    if BufUtils.open_this_buffer_in_gui?(opts) do
      #TODO maybe replace this with GUI.Controller.fire_action({:show, buf}) - it' more consistent with the rest of flamelex, and then we dont need to keep adding new interface functions inside gui controller
      :ok = Flamelex.GUI.Controller.show(buf)
    end

    new_radix_state =
      radix_state
      |> RadixState.set_active_buffer(buf)

    IO.puts "CASTING!!\n\n\n"
    GenServer.cast(Flamelex.FluxusRadix, {:reducer_callback, new_radix_state})
    IO.puts "DONEONEONE"
  end


  def async_reduce(_radix_state,
        {:move_cursor, %{buffer: %BufRef{type: Flamelex.Buffer.Text, ref: ref}, details: details}}
  ) do

    # Flamelex.GUI.Controller.fire_action({})

    #TODO eventually we need to go through some kind of manager, to check we dont overrun the line etc... but for now...
    # we just go to the cursor component directly!!
    {:gui_component, {:text_cursor, ref, 1}}
    |> ProcessRegistry.find!()
    |> GenServer.cast({:move, details})
  end


  def async_reduce(_radix_state, a) do
    IO.puts "#{__MODULE__} ignoring action: #{inspect a}"
    :ok
  end
end
