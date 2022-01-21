defmodule Flamelex.Buffer.SeniorSupervisor do
  @doc """
  The SeniorSupervisor sits above all Buffer.MiddleManagers.

  it goes:

  SeniorSupervisor
  -> MiddleManager
    -> (Buffer, Task.Supervisor)
  """
  use DynamicSupervisor


  def start_link(args) do
    DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end


  @doc """
  Start the process chain for opening a Buffer.
  """
  def open_buffer!({module, params}) do

    params =
      params
      |> add_this_process_to_callback_list()

    DynamicSupervisor.start_child(__MODULE__, {Flamelex.Buffer.MiddleManager, params})

    # now we wait for the Buffer to finish loading, and it calls us back
    receive do
      {:ok_open_buffer, tag} ->
        tag
      anything_else ->
        raise "received unexpected callback: #{inspect anything_else}"
    after
      :timer.seconds(3) ->
        raise "Buffer failed to open. reason: TimedOut."
    end
  end



  defp add_this_process_to_callback_list(%{callback_list: l} = opts) when is_list(l) and length(l) >= 1 do
    Map.merge(opts, %{callback_list: l ++ [self()]}) # if we need to add to an existing list...
  end
  defp add_this_process_to_callback_list(opts) do
    Map.merge(opts, %{callback_list: [self()]}) # if we need to create the callback_list...
  end
end
