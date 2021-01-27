defmodule Flamelex.Fluxus.Reducers.TextBuffer do
  use Flamelex.Fluxux.ReducerBehaviour
  alias Flamelex.Structs.Buf

  def async_reduce(_radix_state, {:acive_buffer, :move_cursor, %{to: destination}}) do
    # get_active_buffer()
    # |> send :move_cursor to it

    #   ProcessRegistry.find!(buf) |> IO.inspect() |> GenServer.call({:modify, modification})

  end

  # def async_reduce(_radix_state, {%Buf{} = buf, :move_cursor, %{to: destination}}) do

  # end
  def async_reduce(_radix_state, a) do
    IO.puts "#{__MODULE__} ignoring action: #{inspect a}"
    :ok
  end
end
