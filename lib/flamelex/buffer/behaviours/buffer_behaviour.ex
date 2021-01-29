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
      use Flamelex.ProjectAliases
      alias Flamelex.Buffer.Structs.BufferState


      @doc """
      This wrapper around GenServer.start_link/3 ensures a consistent boot
      for all Buffers.
      """
      def start_link(params) do
        case rego_tag(params) do
          :error ->
            {:error, "received invalid params"} #TODO make this better
          tag ->
              IO.puts "\n\ngot the tag!\n\n #{inspect tag}\n\n"
              name = Flamelex.Utilities.ProcessRegistry.via_tuple_name(:gproc, tag)
              GenServer.start_link(__MODULE__, params, name: name)
        end
      end


      @doc """
      All Buffers essentially start the same way.
      """
      @impl GenServer
      def init(params) do
        # ok so here, what we want is - figure out where the params get passd from,
        # where do we want to do  boundary checking?? Maybe we pass raw
        # params all the way, to an after initialize handle_continue,
        # where it can safely look at them & maybe just shut down if it has to,
        # maybe make network requests etc...

        # PubSub.subscribe(topic)

        {:ok, params, {:continue, :boot_sequence}}
      end

      def handle_continue(:boot_sequence, init_params) do
        boot_sequence(init_params) # implemented as a callback - turns params into a %BufferState{}
      end

      # all buffers will answer a `:read` call
      def handle_call(:read, _from, %BufferState{data: data}=state) do
        {:reply, data, state}
      end


      #TODO
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

  @doc """
  Accepts different sets of parameters, returns the name-registration
  used by :gproc, for both registration & lookup
  """
  @callback rego_tag(map()) :: tuple()

  @doc """
  This gets called immediately after init/2, via a handle_continue
  """
  @callback boot_sequence(map()) :: map() #TODO this should be a buffer state struct

end
