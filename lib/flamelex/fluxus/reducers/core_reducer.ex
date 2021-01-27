defmodule Flamelex.Fluxus.Reducers.Core do
  use Flamelex.Fluxux.ReducerBehaviour



  # def execute_action_async(%RadixState{} = radix_state, {:show, :command_buffer}) do

  #   Flamelex.GUI.Component.CommandBuffer.show()

  #   new_radix_state =
  #       radix_state
  #       |> RadixState.set(mode: {:command_buffer_active, :insert})

  #   Flamelex.FluxusRadix
  #   |> send({:ok, new_radix_state})
  # end



  def async_reduce(_radix_state, a) do
    IO.puts "#{__MODULE__} ignoring action: #{inspect a}"
    :ok
  end
end
