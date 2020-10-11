defmodule Flamelex.GUI.ComponentBehaviour do
  @moduledoc """
  The Memex can load different environments.
  """

  #NOTE: When we call use Behaviour, we can not only enforce the behaviour
  #      on a module, but we can automatically import functions etc.
  defmacro __using__(_params) do

    quote do

      # must implement all the callbacks defined in *this* module, `Flamelex.GUI.ComponentBehaviour`
      @behaviour Flamelex.GUI.ComponentBehaviour

      use Scenic.Component
      require Logger


      #NOTE: This is just for convenience, so inside environment modules
      #      we can easily use the unique part of the environment module name
      alias __MODULE__
      alias Flamelex.GUI.Structs.{Coordinates, Dimensions, Frame, Layout}
      alias Flamelex.GUI.Utilities.Draw


      #NOTE: In our case, we always want a component to be passed in a %Frame{}
      #      so we don't need specific ones, each component implements them
      #      the same way
      @impl Scenic.Component
      def verify(%Frame{} = data), do: {:ok, data}
      def verify(_else), do: :invalid_data

      @impl Scenic.Component
      def info(_data), do: ~s(Invalid data)


      #NOTE: The following functions are common to all Flamalex.GUI.Components
      #      and they can share the same implementation

      @impl Scenic.Scene
      def init(%Frame{} = state, _opts) do
        # IO.puts "Initializing #{__MODULE__}..."

        #TODO search for if the process is already registered, if it is, engage recovery procedure
        Process.register(self(), __MODULE__) #TODO this should be gproc

        graph = Reducer.initialize(state)

        {:ok, {state, graph}, push: graph}
      end



      @doc """
      All %Flamelex.GUI.Component{}'s are triggered by being cast an %Action{}.
      """
      def action(a) do
        # remember, __MODULE__ will be the module which "uses" this macro
        GenServer.cast(__MODULE__, {:action, a})
      end

      @doc """
      Trigger a component to redraw itself in the form of the %Scenic.Graph{}
      passed in as a param.
      """
      def redraw(%Scenic.Graph{} = g) do
        # remember, __MODULE__ will be the module which "uses" this macro
        GenServer.cast(__MODULE__, {:redraw, g})
      end
    end
  end


  @doc """
  Each Component must define it's reducer, which is the module which
  accepts a %Scenic.Graph{} + %Action{} -> %Scenic.Graph{state: :updated}
  """
  @callback reducer() :: atom()

end
