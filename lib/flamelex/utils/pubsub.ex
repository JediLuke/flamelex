defmodule Flamelex.Utilities.PubSub do
  use GenServer


  def subscribe() do

  end

  def publish(topic, msg) do
    GenServer.call(__MODULE__, {:publish, topic, msg})
  end

  def unsubscribe() do

  end




  def start_link(params) do
    GenServer.start_link(__MODULE__, params)
  end

  def init(_params) do
    IO.puts "Initializing #{__MODULE__}..."
    Process.register(self(), __MODULE__)
    {:ok, _initial_state = %{}}
  end

  def handle_call() do

  end
end
