defmodule Flamelex.GUI.ComponentBehaviour do
  @moduledoc """
  The Memex can load different environments.
  """
  alias Flamelex.GUI.Structs.Frame

  #NOTE: Here's a little reminder...
  # the __using__ macro allows us to `use ComponentBehaviour` and automatically
  # run, not just the behaviour contract code, but a whole bunch of useful
  # code we want automatically included in all ComponentBehaviours
  defmacro __using__(_params) do

    quote do

      #NOTE: Here's a little reminder...
      # Implementing this behaviour forces all modules which do so to
      # implement all the callbacks defined in *this* module, that is,
      # `Flamelex.GUI.ComponentBehaviour`
      @behaviour Flamelex.GUI.ComponentBehaviour

      use Scenic.Component
      require Logger


      #NOTE: This is just for convenience, so inside environment modules
      #      we can easily use the unique part of the environment module name
      alias __MODULE__
      alias Flamelex.GUI.Structs.{Coordinates, Dimensions, Frame, Layout}
      alias Flamelex.GUI.Utilities.Draw


      #NOTE: In our case, we always want a Component to be passed in a %Frame{}
      #      so we don't need specific ones, each Component implements them
      #      the same way
      @impl Scenic.Component
      def verify({%Frame{} = frame, params}) when is_map(params), do: {:ok, {%Frame{} = frame, params}}
      def verify(_else), do: :invalid_data

      @impl Scenic.Component
      def info(_data), do: ~s(Invalid data)


      #NOTE: The following functions are common to all Flamelex.GUI.Components
      #      and they can share the same implementation, so we include them here


      @doc """
      Just like in Phoenix.LiveView, we mount our components onto an existing
      graph. In our case this is the same for all components though so we
      can abstract it out.
      """
      def mount(%Scenic.Graph{} = graph, %Frame{} = frame, params \\ %{}) do
        graph |> add_to_graph({frame, params}) #REMINDER: This will pass `frame` to this modules init/2
      end

      @impl Scenic.Scene
      def init({%Frame{} = frame, params}, _opts) do
        Logger.debug "Initializing #{__MODULE__}..."
        register_self()

        graph =
          render(frame, params)                   #REMINDER: render/1 has to be implemented by modules using this behaviour
          |> Frame.decorate_graph(frame, params)  #REMINDER:

        {:ok, {graph, frame}, push: graph}
      end

      def register_self do
        #TODO search for if the process is already registered, if it is, engage recovery procedure
        Process.register(self(), __MODULE__) #TODO this should be gproc
        #TODO this should be {:gui_component, frame.id}, or maybe other way around. It could also subscribe to the channel for this id
      end

      @doc """
      All %Flamelex.GUI.Component{}'s are triggered by being cast an %Action{}. #TODO

      This function allows for nice API, e.g. MenuBar.action({:click, button})
      """
      def action(a) do
        # remember, __MODULE__ will be the module which "uses" this macro

        #TODO: We need some way of knowing that MenuBar has indeed been mounted
        #      somewhere, or else the messages just go into the void (use call instead of cast?)

        GenServer.cast(__MODULE__, {:action, a})
      end

      @impl Scenic.Scene
      # def handle_cast({:action, action}, {%Scenic.Graph{} = graph, %Frame{} = frame}) do
      def handle_cast({:action, action}, {graph, frame}) do
        #TODO maybe we can get away with not passing in the graph to handle_action...
        case handle_action({graph, frame}, action) do
          :ignore_action
            -> {:noreply, {graph, frame}}
          {:redraw_graph, %Scenic.Graph{} = new_graph}
            -> {:noreply, {new_graph, frame}, push: new_graph}
          {:update_frame, %Frame{} = new_frame}
            -> {:noreply, {graph, new_frame}}
          {:update_frame_and_graph, {%Scenic.Graph{} = new_graph, %Frame{} = new_frame}}
            -> {:noreply, {new_graph, new_frame}, push: new_graph}
        end
      end
    end
  end


  @doc """
  This is called when the scene first renders. It appends the Scene (which
  is represented by Scenic as a reference to a `Scenic.Component` process,
  see: #TODO-[fetch link] for more info)

  We have actually implemented this in the __using__ macro, but my heart
  tells me to leave this here anyway... maybe it'll save us some pain later.
  """
  @callback mount(%Scenic.Graph{}, any()) :: %Scenic.Graph{}

  @doc """
  Each Component is represented internally at the highest level by the
  # %Frame{} datastructure. This function takes in that Component definition
  # and returns a %Scenic.Graph{} which can be drawn by Scenic.
  """
  @callback render(%Frame{}) :: %Scenic.Graph{}

  @doc """
  This function may be implemented as many times as necessary, to handle
  any variety of action. You send Components actions by calling them, e.g.char()

  MenuBar.action({:click, button})

  Then, the Component.MenuBar must implement a corresponding handle_action

  ```
  def handle_action({:click, button}) do
    #   .... whatever
    #   ....
  ```

  What happens if we don't have a corresponding handle_action? There are
  2 cases... (if you do nothing, then you will get the second case):

    1) You did implement a default handler

    2) You did not implement a default handler

    You are going to crash & see errors #TODO confirm this

    #TODO I want to implement a default catcher, so that rather than crashing
    # we could ignore it, but that looks too annoying for now, see: https://elixirforum.com/t/how-to-inject-macro-functions-at-end-of-module/19434

  """
  #NOTE: Phoenix.LiveView uses this callback to handle events. I want to
  #      be compatible with that idea... I do effectively the same thing,
  #      but I call the concept "actions".
  @callback handle_action(tuple(), any()) :: atom() | tuple() #TODO this type def could definitely be cleaned up...
end
