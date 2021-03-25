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
  def async_reduce(%{mode: current_mode} = radix_state, {:action, {:switch_mode, m}}) do
    Logger.info "switching from `#{inspect current_mode}` to `#{inspect m}` mode..."
    radix_state |> switch_mode(m)
  end

  def async_reduce(radix_state, {:action, {KommandBuffer, :show}}) do
    Logger.debug "#{__MODULE__} calling `:show` on KommandBuffer..."
    GenServer.cast(Flamelex.Buffer.KommandBuffer, :show)
    radix_state |> switch_mode(:kommand)
  end

  def async_reduce(radix_state, {:action, {KommandBuffer, :hide}}) do
    GenServer.cast(Flamelex.Buffer.KommandBuffer, :hide)
    radix_state |> switch_mode(:normal)
  end

  def async_reduce(radix_state, {:action, {KommandBuffer, :execute}}) do
    GenServer.cast(Flamelex.Buffer.KommandBuffer, :execute)
    radix_state |> switch_mode(:normal)
  end

  def async_reduce(_radix_state, {:action, {KommandBuffer, x}}) do
    Logger.warn "received an unmatched action: #{inspect x} - forwarding to KommandBuffer..."
    GenServer.cast(Flamelex.Buffer.KommandBuffer, x)
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

  def switch_mode(radix_state, m) do
    new_radix_state = %{radix_state|mode: m} # update the state with the new mode
    Flamelex.Utils.PubSub.broadcast([ #TODO is this even broadcasting anything??
      topic: :gui_update_bus,
      msg: {:switch_mode, m}])
    GenServer.cast(Flamelex.FluxusRadix, {:radix_state_update, new_radix_state})
  end
end
