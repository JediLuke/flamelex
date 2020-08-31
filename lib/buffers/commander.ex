defmodule Franklin.Buffer.Commander do
  @moduledoc """
  Processes command buffer commands.
  """
  use GenServer
  require Logger
  use Franklin.Misc.CustomGuards

  def start_link([] = _default_params) do
    GenServer.start_link(__MODULE__, Buffer.new(:command)) #NOTE: no need to use gproc for the commander
  end

  def execute(command) when is_binary(command) do
    GenServer.cast(__MODULE__, {:command_buffer_command, command})
  end

  def activate do
    # #TODO so actually this sends a msg to the buffer, which may choose to ignore it, but will then use the Gui.Reducer to process what a new graph will look like, & send it to the GUI process
    # GUI.Component.CommandBuffer.action('ACTIVATE_COMMAND_BUFFER_PROMPT')
    # GUI.Scene.Root.action('ACTIVATE_COMMAND_BUFFER')
    GUI.activate_command_buffer()
  end

  def deactivate do
    GUI.Component.CommandBuffer.action('DEACTIVATE_COMMAND_BUFFER')
  end

  def enter_character(char) when is_binary(char) do
    GenServer.cast(__MODULE__, {:enter_char, char})
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
    :timer.sleep(500) #TODO, this is necessary because the Root Scene is not started in sequence by Scenic, so we can't guarantee it is up yet when we start the application...
    GUI.Component.CommandBuffer.initialize(state)
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:enter_char, char}, state) do
    new_state =
      case state.content do
        nil                 -> %{state|content: char}
        c when is_binary(c) -> %{state|content: state.content <> char}
      end

    GUI.Component.CommandBuffer.action({:update_content, new_state.content})
    GUI.Component.CommandBuffer.move_cursor()
    {:noreply, new_state}
  end

  # @impl true
  # def handle_cast({:command_buffer_command, command}, state) do
  #   case command do
  #     "note" ->
  #         new_note() #TODO change to tidbit, with note tags
  #         {:noreply, state}
  #     "list notes" ->
  #         list_notes()
  #         {:noreply, state}
  #     "help" ->
  #         raise "Help is no implemented, and it should be!!"
  #         {:noreply, state}
  #     "reload" ->
  #         Logger.warn "Sending `kill` to GUI.Scene.Root..."
  #         IEx.Helpers.recompile
  #         Process.exit(Process.whereis(GUI.Scene.Root), :kill)
  #         {:noreply, state}
  #     "restart" ->
  #         Logger.warn "Restarting Franklin..."
  #         :init.restart()
  #         {:noreply, state}
  #     unrecognised_command ->
  #         Logger.warn "#{__MODULE__} unrecognised command. Attempting to run as Elixir code... #{inspect unrecognised_command}"
  #         Code.eval_string(unrecognised_command)
  #         {:noreply, state}
  #   end
  # end

  # def new_note do
  #   Franklin.BufferSupervisor.note(%{title: "", text: ""})
  # end

  # def list_notes do
  #   Franklin.BufferSupervisor.list(:notes)
  # end
end
