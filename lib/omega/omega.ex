defmodule Flamelex.OmegaMaster do
  @moduledoc """
  The OmegaMaster holds all global state, acts as a conduit for all
  user-input, and manages modes. We need a single junction-point where
  all the data required to make decisions can be combined & acted upon -
  this is it.

  All inputs get sent here, & then thrown into the Omega.Reducer (along with
  the OmegaState, which represents the global-variables for Flamelex).
  """
  use GenServer
  require Logger
  use Flamelex.CommonDeclarations
  alias Flamelex.Structs.OmegaState


  def start_link([] = _default_params) do
    initial_state = OmegaState.new()
    GenServer.start_link(__MODULE__, initial_state)
  end

  @doc """
  This function handles user input. All input from the entire GUI routes
  through here.

  We use the state of the root scene (which may include global variables
  such as which mode we are in, and the recent input history, to allow
  chaining of keystrokes), as well as the input itself, to compute the new
  state, as well as fire off any secondary events or updates that this
  input requests.
  """
  def handle_input(input) do
    GenServer.cast(__MODULE__, {:handle_input, input})
  end

  ## GenServer callbacks
  ## -------------------------------------------------------------------


  def init(%OmegaState{} = omega_state) do
    Logger.info "Initializing #{__MODULE__}..."
    Process.register(self(), __MODULE__)
    {:ok, omega_state}
  end

  def handle_cast({:handle_input, input}, omega_state) do
    #NOTE: GUI updates are done as side-effects in the Reducer
    new_omega_state =
      %OmegaState{} =
        Flamelex.Omega.Reducer.handle_input(omega_state, input)

    {:noreply, new_omega_state}
  end
end
