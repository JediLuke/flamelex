defmodule Franklin.Buffer.Commander do
  @moduledoc """
  Processes command buffer commands.
  """
  use GenServer
  require Logger
  alias Structs.Buffer

  def start_link([] = _default_params) do
    GenServer.start_link(__MODULE__, Buffer.new(:command_buffer)) #NOTE: no need to use gproc for the commander
  end

  def process(command) when is_binary(command) do
    GenServer.cast(__MODULE__, {:command_buffer_command, command})
  end

  def activate do
    # #TODO so actually this sends a msg to the buffer, which may choose to ignore it, but will then use the Gui.Reducer to process what a new graph will look like, & send it to the GUI process
    # IO.puts "ACTIVATE"
    # GUI.Component.CommandBuffer.action('ACTIVATE_COMMAND_BUFFER_PROMPT')
    GUI.activate_command_buffer()
  end

  def deactivate do
    GUI.Component.CommandBuffer.action('DEACTIVATE_COMMAND_BUFFER')
  end

  def enter_character(char) when is_binary(char) do
    GUI.Component.CommandBuffer.action({'ENTER_CHARACTER', char})
  end


  ## GenServer callbacks
  ## -------------------------------------------------------------------


  @impl true
  def init(%Buffer{} = state) do
    Logger.info "Initializing #{__MODULE__}..."
    Process.register(self(), __MODULE__)
    {:ok, state, {:continue, :initialize_gui}}
  end

  @impl GenServer
  def handle_continue(:initialize_gui, state) do
    IO.puts "Initializing GUI ???"
    :timer.sleep(500) #TODO, this is necessary because the Root Scene is not started in sequence by Scenic, so we can't guarantee it is up yet when we start the application...
    GUI.Component.CommandBuffer.initialize(state)
    {:noreply, state}
  end

  @impl true
  def handle_cast({:command_buffer_command, command}, state) do
    case command do
      "note" ->
          new_note() #TODO change to tidbit, with note tags
          {:noreply, state}
      "list notes" ->
          list_notes()
          {:noreply, state}
      "help" ->
          raise "Help is no implemented, and it should be!!"
          {:noreply, state}
      "reload" ->
          Logger.warn "Sending `kill` to GUI.Scene.Root..."
          IEx.Helpers.recompile
          Process.exit(Process.whereis(GUI.Scene.Root), :kill)
          {:noreply, state}
      "restart" ->
          Logger.warn "Restarting Franklin..."
          :init.restart()
          {:noreply, state}
      unrecognised_command ->
          Logger.warn "#{__MODULE__} unrecognised command. Attempting to run as Elixir code... #{inspect unrecognised_command}"
          Code.eval_string(unrecognised_command)
          {:noreply, state}
    end
  end

  def new_note do
    Franklin.BufferSupervisor.note(%{title: "", text: ""})
  end

  def list_notes do
    Franklin.BufferSupervisor.list(:notes)
  end
end
