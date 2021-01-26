defmodule Flamelex.Fluxus.RootReducer do
  alias Flamelex.Fluxus.Structs.RadixState


  def handle(%RadixState{} = radix_state, {:action, a}) do

    # we spin up a task for each reducer, for them to handle it (or not)

    #TODO automate this, search for compiled modules or something - maybe each module which uses ReducerBehaviour registers itself somehow
    all_reducers = [
      Flamelex.Fluxus.Reducers.Core,
      Flamelex.Fluxus.Reducers.Buffer,
      Flamelex.Fluxus.Reducers.Journal,
    ]

    all_reducers |> Enum.each(fn reducer_module ->
      Task.Supervisor.start_child(
        Flamelex.Fluxus.HandleAction.TaskSupervisor,
        reducer_module,             # module
        :async_reduce,              # function
        [radix_state, a]            # args
      )
    end)
  end

end


    #TODO maybe Enum.each reducer?? Again, doesn't rly matter if they crash, right??

    #TODO might work too??
    # reducer_module = search_for_reducer(radix_state, a)



    #NOTE - we can also import them all using macros, & then pattern match
    #       here, & have 1 match right at the end as a catchall (or, let it crash...)

    #NOTE: handle must return an ok/error tuple, & may update the RadixState

    #TODO this is the tough thing... how do we update the state, if we
    # want to broadcast to multiple reducers?
    # receive do
    #   {:ok, %RadixState{} = new_radix_state} ->
    #     {:ok, new_radix_state}

    #     #TODO other option to try is, we never wait for callbacks, we just
    #     # allow reducers to optionally send us callbacks which we can catch

    #     # I think this might actually be a good path...

    # after
    #   @action_timeout ->
    #     {:error, "timed out waiting for a callback from the action handling process"}
    # end

  # def execute_action_async(%RadixState{} = radix_state, unmatched_action) do
  #   IO.puts "received an action, that we just can't handle... #{inspect unmatched_action}"
  #   Flamelex.FluxusRadix |> send({:ok, radix_state})
  # end
