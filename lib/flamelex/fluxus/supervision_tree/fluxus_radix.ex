defmodule Flamelex.FluxusRadix do
  @moduledoc """
  In latin, `fluxus` means "flow" and `radix` means "root". FluxusRadix
  is the root node in the state-tree of fluxus processes.The FluxusRadix
  holds the highest-level flamelex state, including:

    - the user-input mode
    - the input history (both keystrokes, & commands)
    - it acts as a conduit for all user-input (which got sent
      here by `Flamelex.GUI.RootScene`)

  We need a single junction-point where all the data required to make
  decisions can be combined & acted upon - this is it.

  What belongs in the domain of FluxState? Anything which affects both
  buffers & GUI components. e.g. opening the Command buffer requires:
  * changing the input mode
  * checking the contents of `Flamelex.Buffer.Command`
  * rendering the GUI.Component
  * etc...
  changing the input mode alone requires that we make our changes at the
  FluxusRadix level, so we might as well just put the rest as side-effects
  in the reducer at this level. This makes sense because it's a heirarchy -
  since we need to change the input it's an FluxusRadix level change, so
  the function to open the Command buffer must be implemented at this level.
  If we don't need to alter anything at this level, then do not implement
  it in a reducer/handler at this level, handle it somewhere lower.

  When we need to trigger something at the Radix level, we can use actions.
  Actions get handled by the TansStatum module, though the actual processing
  occurs in a seperate process, running under the
  `Flamelex.Fluxus.HandleAction.TaskSupervisor`.

  User input also gets funneled through this process - the FluxState (which
  includes the user-input history) and the input itself are handled by
  one of the InputHandler functions, which operate in basically the same
  manner as reducers - spun up into their own process & handled in there.
  Inputs usually lead to an action being dispatched, which is sent back
  to FluxusRadix (kind of a loop-back) to be then handled.
  """
  use GenServer
  use Flamelex.ProjectAliases
  alias Flamelex.Structs.FluxState


  def start_link(_params) do
    initial_state = FluxState.new()
    GenServer.start_link(__MODULE__, initial_state)
  end

  @doc """
  This function enables us to fire actions off which enact changes, at
  the FluxusRadix level, but which aren't stricly responses to user input.
  """
  def handle_action(a) do
    GenServer.cast(__MODULE__, {:action, a, []})
  end

  #NOTE: If the process dispatching this action requires a callback, that's possible
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

  @doc """
  This function is called to channel all user input, e.g. keypresses,
  through the FluxusRadix, where they can be converted into actions.

  This function handles user input. All input from the entire GUI gets
  routed through here (it gets sent here by Flamelex.GUI.RootScene.handle_input/3)

  We use the FluxState (which includes global variables such as which
  mode we are in, the input history [to allow chaining of keystrokes\] etc),
  as well as the input itself, to compute the new state.

  The effect of most user input will be either to ignore it, or to dispatch
  an action - this is achieved by sending a new msg to the FluxusRadix, which
  will in turn be handled by spinning up a new Task process to handle it.
  """
  def handle_user_input(ii) do
    GenServer.cast(__MODULE__, {:user_input, ii})
  end

  # @doc """
  # This exists because sometimes it's convenient to call it from IEx to get
  # the value in FluxusRadix

  # iex> FluxusRadix.debug
  # """
  # def debug, do: GenServer.cast(__MODULE__, :debug)



  def init(%Flamelex.Structs.FluxState{} = flux_state) do
    IO.puts "#{__MODULE__} initializing..."
    Process.register(self(), __MODULE__)
    {:ok, flux_state}
  end

  def handle_cast({:user_input, event}, flux_state) do
    Flamelex.FluxusRadix.TransStatum.handle(flux_state, {:user_input, event})
    {:noreply, flux_state}
  end

  def handle_cast({:action, a, _list?}, flux_state) do
    case flux_state |> Flamelex.FluxusRadix.TransStatum.handle({:action, a}) do
      {:ok, %FluxState{} = updated_flux_state} ->
          {:noreply, updated_flux_state |> FluxState.record(action: a)}
      {:error, reason} ->
          IO.puts "error proc action #{inspect a}, #{inspect reason}"
          {:noreply, flux_state}
    end
  end
end
