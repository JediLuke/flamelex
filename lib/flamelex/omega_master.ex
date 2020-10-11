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
  use Flamelex.ProjectAliases
  alias Flamelex.Structs.OmegaState


  def start_link(_params) do
    initial_state = OmegaState.init()
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
    Logger.debug "handling input in #{__MODULE__} - #{inspect input}"
    GenServer.cast(__MODULE__, {:handle_input, input})
  end

  @doc """
  This function enables us to fire actions off which enact changes, at
  the OmegaMaster level, but which aren't stricly responses to user input.
  """
  # def action(a) do
  #   GenServer.cast(__MODULE__, {:action, a})
  # end

  ## GenServer callbacks
  ## -------------------------------------------------------------------


  def init(%OmegaState{} = omega_state) do
    IO.puts "#{__MODULE__} initializing..."
    Process.register(self(), __MODULE__)
    {:ok, omega_state}
  end

  def handle_cast({:handle_input, input}, omega_state) do
    #NOTE: actions may be pushed down to other buffers by Flamelex.Omega.Reducer
    new_omega_state =
      omega_state
      |> Flamelex.InputHandler.handle_input(input)

    {:noreply, new_omega_state}
  end

  # def handle_cast({:action, a}, omega_state) do
  #   new_omega_state =
  #     omega_state
  #     # |> Flamelex.Omega.Reducer.process_action(a)

  #   {:noreply, new_omega_state}
  # end
end
