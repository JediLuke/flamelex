defmodule Flamelex.BufferBehaviour do
  @moduledoc """
  Defines the interface for a Flamelex.Buffer
  """


  defmacro __using__(_params) do
    quote do

      # all buffers have the same basic function, so they can all define
      # the same struct, and then simply have different fields for data
      defstruct [
        name:     nil,  # a *unique* identifier. This will be used to
                        # register processes across various functions e.g.
                        # {:buffer, name} and {:gui_component, name}.
                        # could be a tuple itself, e.g. {"Count of Monte Cristo", :page, 78}
        slug:     nil,  # a short, non-unique (?), simple string used for
                        # conveniently accessing buffers, e.g. "countMC78"
                        # or "buffer1"
        title:    nil,  # a title for the buffer
        data:     nil,  # This field contains all the actual content of the buffer
        opts:     nil,  # a list which can store options, such as starting
                        # a GUI.Component when the Buffer loads
      ]

      #REMINDER: including this @behaviour in the __using__ macro here means
      #          that any module which calls `use Flamelex.BufferBehaviour`
      #          must implement all the callbacks defined in *this* module,
      #          `Flamelex.GUI.ComponentBehaviour`, or else a warning is raised.
      @behaviour Flamelex.BufferBehaviour

      use GenServer
      require Logger

      #NOTE: can't `use Flamelex.ProjectAliases` here for some reason
      # alias Flamelex.Structs.{Buffer}


      @doc """
      This wrapper around GenServer.start_link/3 ensures a consistent boot
      for all Buffers.
      """
      def start_link(params) do
        #TODO proper name registry lmao
        GenServer.start_link(__MODULE__, params, name: __MODULE__)
      end

      @doc """
      Return a Buffer struct.
      """
      #TODO this should use changesets...
      #NOTE: The only mandatory key when creating a buffer is a name (which
      #      is supposed to be unique... this is handled by BufferManager)
      def new(%{name: name} = params) do

        # check params for keys
        title = if params |> Map.has_key?(:title), do: params.title, else: nil
        slug  = if params |> Map.has_key?(:slug),  do: params.slug,  else: nil
        data  = if params |> Map.has_key?(:data),  do: params.data,  else: nil
        opts  = if params |> Map.has_key?(:opts),  do: params.opts,  else: nil

        %__MODULE__{
          name:  name,
          title: title,
          slug:  slug,
          data:  data,
          opts:  opts
        }
      end

      @doc """
      All Buffers essentially start the same way.
      """
      @impl GenServer
      def init({%__MODULE__{} = buf, opts}) do
        Logger.info "#{__MODULE__} initializing... opts: #{inspect opts}"
        # if open_in_gui?(opts), do: GenServer.cast(self(), :show)
        {:ok, buf}
      end



      def read(name) do
        #TODO use gproc to look up the buffer
        GenServer.call(name, :read_contents)
      end

      def handle_call(:read_contents, _from, state) do
        {:reply, state.data, state}
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

        # def clear do
      #   find_pid() |> GenServer.cast(:clear)
      # end

      ## private functions

      defp open_in_gui?(opts) do
        case Keyword.fetch(opts, :show_in_gui?) do
          {:ok, show_in_gui?} -> show_in_gui?
          :error              -> false
        end
      end
    end
  end


  # @doc """
  # Opening a buffer spawns a process which is reponsible for managing the
  # data inside itself.
  # """
  # @callback open(any()) :: any()

end
