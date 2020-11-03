defmodule Flamelex.OmegaMaster do
  @moduledoc """
  The OmegaMaster holds all global state, acts as a conduit for all
  user-input, and manages modes. We need a single junction-point where
  all the data required to make decisions can be combined & acted upon -
  this is it.

  All inputs get sent here, & then thrown into the Omega.Reducer (along with
  the OmegaState, which represents the global-variables for Flamelex).

  What belongs in the domain of OmegaState? Anything which affects both
  buffers & GUI components. e.g. opening the Command buffer requires:

  * changing the input mode
  * checking the contents of `Flamelex.Buffer.Command`
  * rendering the GUI.Component


  """
  use GenServer
  require Logger
  use Flamelex.ProjectAliases
  alias Flamelex.Structs.OmegaState
  alias Flamelex.BufferManager


  def start_link(_params) do
    initial_state = OmegaState.init()
    GenServer.start_link(__MODULE__, initial_state)
  end

  #TODO having these here, is just noise... this is not an interface module
  def switch_mode(m) do
    GenServer.cast(__MODULE__, {:switch_mode, m})
  end

  def open_buffer(params) do
    GenServer.call(__MODULE__, {:open_buffer, params})
  end

  def show(:command_buffer = x) do
    GenServer.cast(__MODULE__, {:show, x})
  end

  def hide(:command_buffer = x) do
    GenServer.cast(__MODULE__, {:hide, x})
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

    new_omega_state =
      omega_state #REMINDER: actions may be pushed down to other buffers by this reducer
      |> Flamelex.GUI.Control.UserInput.Handler.handle_input(input)

    {:noreply, new_omega_state}
  end

  def handle_cast({:switch_mode, m}, omega_state) do

    {:gui_component, omega_state.active_buffer}
    |> ProcessRegistry.find!
    |> GenServer.cast({:switch_mode, m})

    # :ok = GUI.Controller.switch_mode(m)

    {:noreply, %{omega_state|mode: m}}
  end



  #TODO maybe x will be worth considering eventually???
  def handle_cast({:show, :command_buffer}, omega_state) do
    case Buffer.read(:command_buffer) do
      data when is_bitstring(data) ->
        new_omega_state = %{omega_state|mode: :command}
        #TODO so this should then be responsible for managing the buffer process (starting/stopping/finding if sleeping) nd causing it to refresh, whilst also making it visible by forcing a redraw
        Flamelex.GUI.Component.CommandBuffer.show()
        {:noreply, new_omega_state}
      e ->
        raise "Unable to read Buffer.Command. #{inspect e}"
    end
  end

  def handle_cast({:hide, :command_buffer}, omega_state) do
    # GUI.Controller.hide(:command_buffer)
    Flamelex.GUI.Component.CommandBuffer.hide()
    {:noreply, %{omega_state|mode: :normal}}
  end

  def handle_call({:open_buffer, %{
    type: :text,
    from_file: filepath,
    open_in_gui?: true
  } = params}, _from, omega_state) do

    {:ok, new_buf} = BufferManager.open_buffer(params)

    :ok = GUI.Controller.show({:buffer, filepath}, omega_state)

    {:reply, {:ok, new_buf}, %{omega_state|active_buffer: new_buf}}
  end

  def handle_call({:open_buffer, %{name: name, open_in_gui?: true} = params}, _from, omega_state) do

    {:ok, new_buf} = BufferManager.open_buffer(params)

    :ok = GUI.Controller.show({:buffer, name}, omega_state)

    {:reply, {:ok, new_buf}, %{omega_state|active_buffer: new_buf}}
  end

  # def handle_cast({:action, a}, omega_state) do
  #   new_omega_state =
  #     omega_state
  #     # |> Flamelex.Omega.Reducer.process_action(a)

  #   {:noreply, new_omega_state}
  # end
end
