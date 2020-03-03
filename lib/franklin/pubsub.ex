defmodule Franklin.PubSub do
  @moduledoc false
  use GenServer
  require Logger

  def start_link([] = default_params) do
    GenServer.start_link(__MODULE__, default_params)
  end

  def subscribe(topic, pid) do
    GenServer.cast(__MODULE__, {:subscribe, topic, pid})
  end

  def unsubscribe(topic, pid) do
    GenServer.cast(__MODULE__, {:unsubscribe, topic, pid})
  end

  def publish(topic, msg) do
    GenServer.cast(__MODULE__, {:publish, topic, msg})
  end

  def fetch_subscriptions() do
    GenServer.call(__MODULE__, :fetch_subscriptions)
  end


  ## GenServer callbacks
  ## -------------------------------------------------------------------


  @impl true
  def init(_params) do
    Process.register(self(), __MODULE__)
    {:ok, _initial_state = %{}}
  end

  @impl true
  def handle_call(:fetch_subscriptions, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:subscribe, topic, pid}, state) when is_atom(topic) do
    if Map.has_key?(state, topic) do
      new_state = Map.replace!(state, :topic, state.topic ++ [pid])
      {:noreply, new_state}
    else
      new_state = state |> Map.merge(%{topic => [pid]})
      {:noreply, new_state}
    end
  end
end
