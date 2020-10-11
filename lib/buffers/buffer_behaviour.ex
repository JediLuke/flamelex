defmodule Flamelex.BufferBehaviour do
  @moduledoc """
  Defines the interface for a Flamelex.Buffer
  """


  defmacro __using__(_params) do

    quote do

      # must implement all the callbacks defined in *this* module, `Flamelex.GUI.ComponentBehaviour`
      @behaviour Flamelex.BufferBehaviour

      use GenServer
      require Logger

      #NOTE: can't `use Flamelex.ProjectAliases` here for some reason
      alias Flamelex.Structs.{Buffer}

      @doc """
      This wrapper around GenServer.start_link/3 ensures a consistent boot
      for all Buffers.
      """
      def start_link(params) do
        buf  = Buffer.new(params)
        name = Flamelex.Utilities.ProcessRegistry.via_tuple(buf.name)
        GenServer.start_link(__MODULE__, buf, name: name)
      end

      @doc """
      All Buffers essentially start the same way.
      """
      @impl GenServer
      def init(%Buffer{} = buf, open_buffer? \\ true) do
        Logger.info "#{__MODULE__} initializing... type: #{inspect buf.type}, name: #{buf.name}"
        if open_buffer?, do: GenServer.cast(self(), :show)
        {:ok, buf}
      end

      @doc """
      All Buffers support show/hide
      """
      @impl GenServer
      def handle_cast(:show, buf) do
        Flamelex.GUI.Controller.action({:show, buf})
        {:noreply, buf}
      end

      def handle_cast(:hide, buf) do
        Flamelex.GUI.Controller.action({:hide, buf})
        {:noreply, buf}
      end
    end
  end


  @doc """
  Each Component must define it's reducer, which is the module which
  accepts a %Scenic.Graph{} + %Action{} -> %Scenic.Graph{state: :updated}
  """
  # @callback reducer() :: atom()

end
