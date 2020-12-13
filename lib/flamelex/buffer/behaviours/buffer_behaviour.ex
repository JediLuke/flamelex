defmodule Flamelex.BufferBehaviour do
  @moduledoc """
  Defines the interface for a Flamelex.Buffer
  """

          # open_time: DateTime.utc_now()

  defmacro __using__(_params) do
    quote do

      #REMINDER: including this @behaviour in the __using__ macro here means
      #          that any module which calls `use Flamelex.BufferBehaviour`
      #          must implement all the callbacks defined in *this* module,
      #          `Flamelex.GUI.ComponentBehaviour`, or else a warning is raised.
      @behaviour Flamelex.BufferBehaviour

      use GenServer
      require Logger


      @doc """
      This wrapper around GenServer.start_link/3 ensures a consistent boot
      for all Buffers.
      """
      def start_link(params) do
        #TODO proper name registry lmao
        GenServer.start_link(__MODULE__, params, name: __MODULE__)
      end


      @doc """
      All Buffers essentially start the same way.
      """
      @impl GenServer
      def init({%__MODULE__{} = buf, opts}) do
        Logger.info "#{__MODULE__} initializing... opts: #{inspect opts}"
        {:ok, buf}
      end


      def read(name) do
        #TODO use gproc to look up the buffer
        GenServer.call(name, :read_contents)
      end


      def handle_call(:read_contents, _from, state) do
        #TODO should this return on ok/error tuple?
        {:reply, state.data, state}
      end


      # @doc """
      # All Buffers support show/hide
      # """
      # @impl GenServer
      # def handle_cast(:show, buf) do
      #   Flamelex.GUI.Controller.action({:show, buf})
      #   {:noreply, buf}
      # end

      # def handle_cast(:hide, buf) do
      #   Flamelex.GUI.Controller.action({:hide, buf})
      #   {:noreply, buf}
      # end
    end
  end


  # @doc """
  # Opening a buffer spawns a process which is reponsible for managing the
  # data inside itself.
  # """
  # @callback open(any()) :: any()

end
