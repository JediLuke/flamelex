defmodule Flamelex.Fluxus.Reducers.Buffer do #TODO rename module
  # quote do
    use Flamelex.Fluxux.ReducerBehaviour
    require Logger


    def handle(params) do
      # spin up a new process to do the handling...
      Task.Supervisor.start_child(
          Flamelex.Buffer.Reducer.TaskSupervisor,
              __MODULE__,
              :async_reduce,  # call the `async_reduce` function, defined below
              [params]        # and pass it the params
        )
    end


  #   def async_reduce(_radix_state, {:move_cursor, %{buffer: buffer_tag, details: details}}) do #TODO I dunno if I like this or not
  #     buffer_tag
  #     |> ProcessRegistry.find!()
  #     |> GenServer.cast({:move_cursor, details})
  #   end


  def async_reduce(
        %{action: {:open_buffer, opts}, radix_state: radix_state }) do

    # step 1 - open the buffer
    buf = Flamelex.Buffer.open!(opts)

    # step 2 - update FluxusRadix (because we forced a root-level update)
    radix_update =
      {:radix_state_update, radix_state |> RadixState.set_active_buffer(buf)}
    GenServer.cast(Flamelex.FluxusRadix, radix_update)

  end


  # below here are the pattern match functions to handle actions we
  # receive but we want to ignore


  def async_reduce(%{action: name}) do
    Logger.warn "#{__MODULE__} ignoring an action... #{inspect name}"
    :ignoring_action
  end

  def async_reduce(unmatched_action) do
    Logger.warn "#{__MODULE__} ignoring an action... #{inspect unmatched_action}"
    :ignoring_action
  end
end
