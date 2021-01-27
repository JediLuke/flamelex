defmodule Flamelex.Fluxus.Reducers.Buffer do
  use Flamelex.Fluxux.ReducerBehaviour
  alias Flamelex.Buffer.BufUtils


  def async_reduce(_radix_state,
    {:open_buffer, {:local_text_file, path: filepath}, opts}
  ) when is_map(opts) do

    opts = Map.merge(opts, %{
      type: Flamelex.Buffer.Text, #TODO yuck
      from_file: filepath,
      open_in_gui?: true, #TODO remove
    })

    buf = Flamelex.Buffer.open!(opts)

    if BufUtils.open_this_buffer_in_gui?(opts) do
      :ok = Flamelex.GUI.Controller.show(buf)
    end

    #TODO call back to FluxusRadix with results of opening
  end


  def execute_action_async(%RadixState{} = radix_state, {:active_buffer, action, details}) do
    Flamelex.BufferManager.fire_action(radix_state, action, details)
    :ok
  end



  def async_reduce(_radix_state, a) do
    IO.puts "#{__MODULE__} ignoring action: #{inspect a}"
    :ok
  end
end
