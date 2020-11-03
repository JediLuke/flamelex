defmodule Flamelex.Memex.Env.JediLuke.ElixirToolChest.GenServer do

  def template do
    ~s|

    defmodule Sample.GenServer do
      @moduledoc false
      use GenServer
      require Logger


      def start_link([] = default_params) do
        GenServer.start_link(__MODULE__, default_params)
      end


      ## GenServer callbacks
      ## ---------------------------------------------------------------


      @impl GenServer
      def init(_params) do
        IO.puts \"Initializing #{__MODULE__}...\"
        Process.register(self(), __MODULE__)
        {:ok, _initial_state = [], {:continue, :after_init}}
      end

      @impl GenServer
      def handle_continue(:after_init, state) do
        send self(), :example_info_msg
        {:noreply, state}
      end

      @impl GenServer
      def handle_call({:example_call, data}, _from, state) do
        result = some_func()
        {:reply, result, state}
      end

      @impl GenServer
      def handle_cast(:example_cast, state) do
        {:noreply, state}
      end

      @impl GenServer
      def handle_info(:example_info_msg, state) do
        {:noreply, state}
      end

    |
  end

  def template(:init_function) do
    ~s|
    @impl GenServer
    def init(_params) do
      IO.puts \"Initializing #{__MODULE__}...\"
      Process.register(self(), __MODULE__)
      {:ok, _initial_state = [], {:continue, :after_init}}
    end
    |
  end
end
