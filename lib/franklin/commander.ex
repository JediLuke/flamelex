defmodule Franklin.Commander do
  @moduledoc """
  Processes command buffer commands.
  """
  use GenServer
  require Logger

  def start_link([] = default_params) do
    GenServer.start_link(__MODULE__, default_params)
  end

  #TODO RootScene should monitor commander to show errors

  def process(command) when is_binary(command) do
    GenServer.cast(__MODULE__, {:command_buffer_command, command})
  end

  ## GenServer callbacks
  ## -------------------------------------------------------------------


  @impl true
  def init(_params) do
    Logger.info "Initializing #{__MODULE__}..."
    Process.register(self(), __MODULE__)
    {:ok, _initial_state = %{}}
  end

  @impl true
  def handle_cast({:command_buffer_command, command}, state) do
    case command do
      "note" ->
          new_note() #TODO change to tidbit, with note tags
          {:noreply, state}
      "list notes" ->
          raise "Need to be able to list notes!"
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

  def new_note, do: Franklin.BufferSupervisor.note(%{title: "", text: ""})

end
