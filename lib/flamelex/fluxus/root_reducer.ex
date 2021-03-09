defmodule Flamelex.Fluxus.RootReducer do
  @moduledoc """
  The RootReducer for all flamelex actions.

  Actions aren't handles in the caller process, instead a new Task is
  spun up to handle the processing - so any failures are contained to
  that task. The tasks are designed to call back if successful, so if
  they crash, either nothing will happen, or some timeouts will trigger
  if they were set further up the chain.
  """
  use Flamelex.ProjectAliases


  def handle(radix_state, action) do
    # spin up a new process to do the handling...
    Task.Supervisor.start_child(
        Flamelex.Fluxus.RootReducer.TaskSupervisor,
            __MODULE__,
            :async_reduce,          # call the `async_reduce` function, defined below
            [radix_state, action]   # and pass it these two arguments
      )
  end

  @doc """
  Here we have the function which `reduces` a radix_state and an action.

  Our main way of handling actions is simply to broadcast them on to the
  `:actions` broker, which will forward it to all the main Manager processes
  in turn (GUiManager, BufferManager, AgentManager, etc.)

  The reason for this is, what's going to happen is, say I send a command
  like `open_buffer` to open my journal. We spin up this action handler
  task - say that takes 2 seconds to run for some reason. If I send the
  same action again, another process will spin up. Eventually, they're
  both going to finish, and whoever is getting the results (FluxusRadix)
  is going to get 2 messages, and then have to handle the situation of
  dealing with double-processes of actions (yuck!)

  what we want to do instead is, the reducer broadcasts the message to
  the "actions" channel - all the managers are able to react to this event.
  """
  def async_reduce(%{mode: _current_mode} = radix_state, {:action, {:switch_mode, m}}) do
    new_radix_state = %{radix_state|mode: m} # update the state with the new mode
    IO.puts "CHANGE MODE!!"
    GenServer.cast(Flamelex.FluxusRadix, {:radix_state_update, new_radix_state}) # update FluxusRadix
    PubSub.broadcast(topic: :gui_update_bus, msg: {:switch_mode, m})
    :ok
  end

  def async_reduce(radix_state, {:action, {KommandBuffer, x}}) do
    IO.puts "we're trying to do something with KommandBuffer..."
    GenServer.cast(Flamelex.Buffer.KommandBuffer, x)
  end

  def async_reduce(radix_state, {:action, action}) do
    IO.puts "Broadcasting action... #{inspect action}"
    Flamelex.Utils.PubSub.broadcast([
        topic: :action_event_bus,
        msg: %{
          radix_state: radix_state,
          action: action
        }
    ])
  end
end


  # def handle(%RadixState{} = radix_state, {:action, a}) do

  #   # we spin up a task for each reducer, for them to handle it (or not)

  #   # #TODO automate this, search for compiled modules or something - maybe each module which uses ReducerBehaviour registers itself somehow
  #   # all_reducers = [
  #   #   Flamelex.Fluxus.Reducers.Core,
  #   #   Flamelex.Fluxus.Reducers.Buffer,
  #   #   Flamelex.Fluxus.Reducers.Journal,
  #   # ]

  #   # all_reducers |> Enum.each(fn reducer_module ->
  #     Task.Supervisor.start_child(
  #       Flamelex.Fluxus.HandleAction.TaskSupervisor,
  #       __MODULE__,
  #       # reducer_module,             # module
  #       :async_reduce,              # function
  #       [radix_state, a]            # args
  #     )
  #   # end)
  # end






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
