defmodule Flamelex.BufferBehaviour do
  @moduledoc """
  Defines the interface for a Flamelex.Buffer
  """

  defmacro __using__(_params) do
    quote do

      #REMINDER: including this @behaviour in the __using__ macro here means
      #          that any module which calls `use Flamelex.BufferBehaviour`
      #          must implement all the callbacks defined in *this* module,
      #          `Flamelex.GUI.ComponentBehaviour`, or else a warning is raised.
      @behaviour Flamelex.BufferBehaviour
      use GenServer, restart: :transient
      use Flamelex.ProjectAliases
      require Logger


      @doc """
      This wrapper around GenServer.start_link/3 ensures a consistent boot
      for all Buffers.
      """
      #TODO this is currently only going to work for text files...
      def start_link(%{source: source} = params) do
        Logger.debug "#{__MODULE__} starting... params: #{inspect params}"
        tag  = {:buffer, source}
        name = Flamelex.Utilities.ProcessRegistry.via_tuple_name(:gproc, tag)
        GenServer.start_link(__MODULE__, Map.merge(params, %{rego_tag: tag}), name: name)
      end

      def start_link(%{rego_tag: {:buffer, _b} = tag} = params) do #TODO should we enforce this tuple shape here?? dunno
        Logger.debug "#{__MODULE__} starting... params: #{inspect params}"
        name = Flamelex.Utilities.ProcessRegistry.via_tuple_name(:gproc, tag)
        GenServer.start_link(__MODULE__, %{rego_tag: tag, params: params}, name: name)
      end

      def start_link([]) do
        raise "cant start a buffer with no params (yet!)"
      end

      @doc """
      We don't do anything here except start the boot sequence.
      """
      @impl GenServer
      def init(params) do
        {:ok, params, {:continue, :boot_sequence}}
      end

      @impl GenServer
      def handle_continue(:boot_sequence, init_params) do
        # implemented as a callback - uses the `init_params` to finish
        # booting up the buffer, and sets the initial state of the buffer
        {:ok, buf_state} = boot_sequence(init_params)
        {:noreply, buf_state, {:continue, :register_with_buffer_manager}}
      end

      @impl GenServer
      def handle_continue(:register_with_buffer_manager, buf_state) do
        GenServer.cast(Flamelex.BufferManager, {:buffer_opened, buf_state})
        {:noreply, buf_state, {:continue, :send_callbacks}}
      end

      @impl GenServer
      def handle_continue(:send_callbacks, %{callback_list: clist, rego_tag: tag} = buf_state) when is_list(clist) do
        Enum.each(clist, &send(&1, {:ok_open_buffer, tag}))
        {:noreply, buf_state |> Map.delete(:callback_list)}
      end

      @impl GenServer
      # since we didn't match the above case, we must not have any callbacks...
      def handle_continue(:send_callbacks, buf_state) do
        {:noreply, buf_state}
      end

      # all buffers will answer a `:read` call
      @impl GenServer
      def handle_call(:read, _from, state) do
        {:reply, state.data, state}
      end
    end
  end


  @doc """
  This function gets run when a new Buffer starts, it contains startup
  logic for the buffer.

  Each Buffer which implements the BufferBehaviour already has the
  GenServer functions `start_link/1` and `init/1` implemented. After `init/1`
  has run, it uses the `handle_continue` mechanism to call this function
  `boot_sequence/1`, which must be implemented in the actual Buffer module.
  """
  @callback boot_sequence(map()) :: any()

end
