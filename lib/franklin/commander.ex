defmodule Franklin.Commander do
  @moduledoc """
  Processes command buffer commands.
  """
  use GenServer
  require Logger

  def start_link([] = default_params) do
    GenServer.start_link(__MODULE__, default_params)
  end

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
        IO.puts "Here we will create a new note!"
        {:noreply, state}
      "Luke is the best" ->
        IO.puts "Yes he is!"
        {:noreply, state}
      other_command ->
        Logger.warn "#{__MODULE__} unrecognised command: #{inspect other_command}"
        {:noreply, state}
    end
  end
end
