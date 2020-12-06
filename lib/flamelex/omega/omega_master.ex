defmodule Flamelex.OmegaMaster do
  @moduledoc """
  The OmegaMaster holds the highest-level flamelex state.

  The OmegaMaster holds all global state, including:
    - the user-input mode
    - the input history (both keystrokes, & commands)
    - it acts as a conduit for all user-input (which got sent
      here by `Flamelex.GUI.RootScene`)

  We need a single junction-point
  where all the data required to make decisions can be combined & acted
  upon - this is it.

  What belongs in the domain of OmegaState? Anything which affects both
  buffers & GUI components. e.g. opening the Command buffer requires:
  * changing the input mode
  * checking the contents of `Flamelex.Buffer.Command`
  * rendering the GUI.Component
  * etc...
  changing the input mode alone requires that we make our changes at the
  OmegaMaster level, so we might as well just put the rest as side-effects
  in the reducer at this level. This makes sense because it's a heirarchy -
  since we need to change the input it's an OmegaMaster level change, so
  the function to open the Command buffer must be implemented at this level.
  If we don't need to alter anything at this level, then do not implement
  it in a reducer/handler at this level, handle it somewhere lower.

  #TODO
  When we need to trigger something at the Omega level, we can use actions.
  Actions get passed to the reducer.

  User input also gets funneled through this process - the OmegaState (which
  includes the user-input history) and the input itself are handled by
  one of the InputHandler functions, which operate in basically the same
  manner as reducers.
  """
  use GenServer
  use Flamelex.ProjectAliases
  use Flamelex.GUI.ScenicEventsDefinitions
  alias Flamelex.Structs.OmegaState
  require Logger

  # @action_callback_timeout 1_000


  def start_link(_params) do
    initial_state = OmegaState.new()
    GenServer.start_link(__MODULE__, initial_state)
  end

  @doc """
  This function enables us to fire actions off which enact changes, at
  the OmegaMaster level, but which aren't stricly responses to user input.
  """
  def action(a) do
    GenServer.cast(__MODULE__, {:action, a, []})
  end
  # def action(a, await_callback?: true) do
  #   GenServer.cast(__MODULE__, {:action, a, callback_pid: self()})
  #   receive do
  #     callback ->
  #       callback
  #   after
  #     @action_callback_timeout ->
  #       {:error, "timed out waiting for the action to callback"}
  #   end
  # end

  def debug(d), do: GenServer.cast(__MODULE__, {:debug, d})


  # GenServer callbacks


  def init(%Flamelex.Structs.OmegaState{} = omega_state)
  do
    IO.puts "#{__MODULE__} initializing..."
    Process.register(self(), __MODULE__)
    {:ok, omega_state}
  end

  # This function handles user input. All input from the entire GUI
  # gets routed through here (it gets sent here by
  # Flamelex.GUI.RootScene.handle_input/3)
  #
  # We use the state of the root scene (which may include global variables
  # such as which mode we are in, and the recent input history, to allow
  # chaining of keystrokes), as well as the input itself, to compute the
  # new state, as well as fire off any secondary events or updates that
  # this input requests.
  # REMINDER: actions may be fired by this reducer, causing side-effects
  # NOTE: ignore all inputs which aren't codepoints
  def handle_cast({:user_input, {:codepoint, _codepoint} = input}, omega_state)
  do
    new_omega_state =
      omega_state
      |> Flamelex.GUI.UserInputHandler.handle_input(input)
      |> OmegaState.record(keystroke: input)

    {:noreply, new_omega_state}
  end
  def handle_cast({:user_input, _input}, omega_state)
  do
    #NOTE: just ignore non :codepoint input
    {:noreply, omega_state}
  end

  def handle_cast({:action, a, opts}, omega_state)
  do
    new_omega_state =
        omega_state
        |> Flamelex.Omega.Reducer.process_action(a, opts)
        |> OmegaState.record(action: a)

    {:noreply, new_omega_state}
  end

  def handle_cast({:debug, d}, omega_state) do
    IO.puts "DEBUG: #{inspect d}, omega_state: #{inspect omega_state.keystroke_history}"
    {:noreply, omega_state}
  end
end
