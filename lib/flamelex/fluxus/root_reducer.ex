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
  require Logger

  alias Flamelex.Fluxus.Reducers.Mode,    as: ModeReducer
  alias Flamelex.Fluxus.Reducers.Kommand, as: KommandReducer


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

  def async_reduce(%{mode: :memex} = radix_state, {:action, {:memex, :new_random}}) do
    Logger.debug "received an action `{:memex, :new_random}` while in :memex mode..."
    t = Memex.random()
    GenServer.cast(:hypercard, {:new_tidbit, t})
  end

  def async_reduce(%{mode: :memex} = radix_state, {:action, {:switch_mode, :normal}} = action) do
    # ModeReducer.handle(radix_state, action)
    Logger.debug "this is where we will take us back to the other view!"
    

    Flamelex.Fluxus.Reducers.Mode.handle(radix_state, {:action, {:switch_mode, :normal}})
    GenServer.cast(Flamelex.GUI.Controller, {:activate, :homebase})
  end

  def async_reduce(radix_state, {:action, {:switch_mode, _m}} = action) do
    ModeReducer.handle(radix_state, action)
  end

  def async_reduce(%{mode: :memex} = radix_state, action) do
    Logger.debug "#{__MODULE__} recv'd an action in Memex :mode. #{inspect action}"

    # ModeReducer.handle(radix_state, action)
    

    # Flamelex.Fluxus.Reducers.Mode.handle(radix_state, {:action, {:switch_mode, :normal}})
    # GenServer.cast(Flamelex.GUI.Controller, {:activate, :homebase})
  end

  #TODO/note - ok so for implementing something, next step is, we need
  #            to implement a fluxus-radix reduceR!
  def async_reduce(radix_state, {:action, :open_memex} = action) do
    Logger.debug "opening the MemexWrap..."
    
    Flamelex.Fluxus.Reducers.Mode.handle(radix_state, {:action, {:switch_mode, :memex}})
    
    #TODO update GUI state - :memex
    GenServer.cast(Flamelex.GUI.Controller, :open_memex)
    :ok
  end

  # def async_reduce(radix_state, {:action, :close_memex} = action) do
  #   Logger.debug "opening the MemexWrap..."
    
  #   Flamelex.Fluxus.Reducers.Mode.handle(radix_state, {:action, {:switch_mode, :memex}})
    
  #   #TODO update GUI state - :memex
  #   GenServer.cast(Flamelex.GUI.Controller, :open_memex)
  #   :ok
  # end

  def async_reduce(radix_state, {:action, {KommandBuffer, _details}} = action) do
    Logger.debug "RootReducer received an action related to the KommandBuffer - forwarding..."
    KommandReducer.handle(radix_state, action)
  end

  # if we get to here, we haven't matched on anything, so it's not a
  # `root` action - we pubish it to the `:action_event_bus`, for each of
  # the managers to handle, if it's relevent to them
  def async_reduce(radix_state, {:action, action}) do
    Logger.debug "#{__MODULE__} did not match any action: #{inspect action} - broadcasting to :action_event_bus..."
    Flamelex.Utils.PubSub.broadcast([
        topic: :action_event_bus,
        msg: %{
          radix_state: radix_state,
          action: action
        }
    ])
  end

end
