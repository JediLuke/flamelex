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

  # def execute(command) when is_binary(command) do
  #   GenServer.cast(__MODULE__, {:command_buffer_command, command})
  # end

  def execute_contents do
    GenServer.cast(__MODULE__, :execute_contents)
  end

  def activate do
    #NOTE: Because this changes the mode, needs to be done by the Root Scene
    GUI.Scene.Root.action(:activate_command_buffer)
  end

  def deactivate do
    #NOTE: Because this changes the mode, needs to be done by the Root Scene
    reset_text_field()
    GUI.Scene.Root.action(:deactivate_command_buffer)
  end

  def enter_character(char) when is_binary(char) do
    GenServer.cast(__MODULE__, {:enter_char, char})
  end

  def reset_text_field, do: GenServer.cast(__MODULE__, :reset_text_field)


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

  @impl GenServer
  def handle_cast(:reset_text_field, state) do
    new_state = %{state|content: ""}

    GUI.Component.CommandBuffer.action({:update_content, new_state.content})
    GUI.Component.CommandBuffer.action(:reset_cursor)

    {:noreply, new_state}
  end

  # @impl GenServer
  # def handle_cast(:deactivate_command_buffer, state) do
  #   new_state = %{state|content: ""}

  #   GenServer.cast(__MODULE__, :reset_text_field)
  #   GUI.Component.CommandBuffer.action(:hide_command_buffer)

  #   {:noreply, new_state} # reset the content to blank
  # end

  # @impl true
  # def handle_cast({:command_buffer_command, command}, state) do

  # end

  @impl GenServer
  def handle_cast(:execute_contents, state) do
    execute_command(state.content)
    deactivate() #TODO this will send :update_content and :reset_cursor again!!
    {:noreply, state}
  end

  # def new_note do
  #   Franklin.BufferSupervisor.note(%{title: "", text: ""})
  # end

  # def list_notes do
  #   Franklin.BufferSupervisor.list(:notes)
  # end

  # def execute_command("new_note") do #TODO change to tidbit, with note tags
  # def execute_command("list_notes") do
  # def execute_command("reload") do
  #         Logger.warn "Sending `kill` to GUI.Scene.Root..."
  #         IEx.Helpers.recompile
  #         Process.exit(Process.whereis(GUI.Scene.Root), :kill)
  #         {:noreply, state}
  # end
  # def execute_command("restart") do
  def execute_command("note") do
    IO.puts "A new note!!"
    :ok
  end

  def execute_command("open") do
    file_name = "/Users/luke/workbench/elixir/franklin/README.md"
    Logger.info "Opening a file... #{inspect file_name}"
    Franklin.CLI.open(file: file_name) # will open as the active buffer
  end

  def execute_command("edit") do
    file_name = "/Users/luke/workbench/elixir/franklin/README.md"

    string = "Luke"
    Franklin.Buffer.Text.insert(file_name, string, after: 3)
  end

  def execute_command(unrecognised_command) do
    Logger.warn "#{__MODULE__} unrecognised command. Attempting to run as Elixir code... #{inspect unrecognised_command}"
    Code.eval_string(unrecognised_command)
  end
end
