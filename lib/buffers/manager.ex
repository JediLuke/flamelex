defmodule Franklin.Buffer.Manager do
  @moduledoc """
  This GenServer is responsible for managing the open buffers.
  """
  use GenServer
  require Logger

  def start_link(params), do: GenServer.start_link(__MODULE__, params, name: __MODULE__)

  @impl true
  def init(params) do
    Logger.info("#{__MODULE__} initializing... #{inspect params}")
    {:ok, params, {:continue, :after_init}}
  end

  @impl true
  def handle_continue(:after_init, _params) do
    state = %{}
    Logger.info("Initialization complete.")
    {:noreply, state}
  end


  ## private functions
  ## -------------------------------------------------------------------


end
