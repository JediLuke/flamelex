defmodule Flamelex.GUI.ComponentBehaviour do
  @moduledoc """
  GUI Components are defined here.
  """

  #TODO either deprecate this component or make it mandatory!!

  defmacro __using__(_params) do
    quote do

      #NOTE: Here's a little reminder...
      # Implementing this behaviour forces all modules which do so to
      # implement all the callbacks defined in *this* module, that is,
      # `Flamelex.GUI.ComponentBehaviour`
      @behaviour Flamelex.GUI.ComponentBehaviour
      use Scenic.Component
      use Flamelex.ProjectAliases
      require Logger


      # validate the incoming arguments when we mount a scene?
      def validate(data) do
        {:ok, data}
      end

      @doc """
      Just like in Phoenix.LiveView, we mount our components onto an existing
      graph. In our case this is the same for all components though so we
      can abstract it out.
      """
      #TODO deprecate, just use add_to_graph
      def mount(%Scenic.Graph{} = graph, %{ref: r} = params) do
        graph |> add_to_graph(params, id: r) #REMINDER: `params` goes to this modules init/2, via verify/1 (as this is the way Scenic works)
      end
      def mount(%Scenic.Graph{} = graph, params) do
        graph |> add_to_graph(params) #REMINDER: `params` goes to this modules init/2, via verify/1 (as this is the way Scenic works)
      end


      #NOTE:
      # In our case, we always want a Component to be passed in a %Frame{}
      # so we don't need specific ones, each Component implements them
      # the same way. Also all components need a `ref`
      def verify(%{
        ref: _r,                # the `ref` refers back to the Buffer that this GUI.Component is for, e.g. {:buffer, {:file, "README.md"}}
        frame: %Flamelex.GUI.Structs.Frame{} = _f    # the %Frame{} which defines this GUI.Component
      } = params) do
        {:ok, params}
      end
      def verify(_else), do: :invalid_data
      @impl Scenic.Component
      def info(_data), do: ~s(Invalid data)


      # def init(%{frame: %Frame{} = frame} = params, _scenic_opts) do
      #   {:rego_tag, _tag} = register_self(params)

      #   #NOTE: This little trick is so that `custom_init_logic` is optional
      #   params =
      #     if function_exported?(__MODULE__, :custom_init_logic, 1) do
      #       apply(__MODULE__, :custom_init_logic, [params])
      #     else
      #       params
      #     end

      #   Flamelex.Utils.PubSub.subscribe(topic: :gui_event_bus)

      #   graph =
      #     #TODO change this to just render/1 eventually...
      #     render(frame, params) #REMINDER: render/1 has to be implemented by the modules "using" this behaviour, and that is the function being called here
      #     |> Frame.draw_frame_footer(params)

      #   {:ok, {graph, params}, push: graph}
      # end


      #TODO maybe put __MODULE__ in here, so we can see what type of component it is in the registration?
      def register_self(%{ref: ref} = params) do
        tag =
          if function_exported?(__MODULE__, :rego_tag, 1) do
            apply(__MODULE__, :rego_tag, [params])
          else
            {:gui_component, ref} #TODO {__MODULE__, ref}
          end

        #TODO search for if the process is already registered, if it is, engage recovery procedure
        #TODO this should be {:gui_component, frame.id}, or maybe other way around. It could also subscribe to the channel for this id
        ProcessRegistry.register(tag)
        {:rego_tag, tag}
      end
    end
  end


  # @doc """
  # This is called when the scene first renders. It appends the Scene (which
  # is represented by Scenic as a reference to a `Scenic.Component` process,
  # see: #TODO-[fetch link] for more info)

  # We have actually implemented this in the __using__ macro, but my heart
  # tells me to leave this here anyway... maybe it'll save us some pain later.
  # """
  # @callback mount(%Scenic.Graph{}, map()) :: %Scenic.Graph{}

  @doc """
  We have a nice little method for initializing all components, but
  sometimes there is some special logic which needs to be done during
  a components init/2 function.

  This is an optional callback. #TODO
  """
  @callback custom_init_logic(map()) :: map()

  @doc """
  Each Component is represented internally at the highest level by the
  %Frame{} datastructure. This function takes in that Component definition
  and returns a %Scenic.Graph{} which can be drawn by Scenic.
  """
  #TODO just make this a map & pass both in the map...
  @callback render(%Flamelex.GUI.Structs.Frame{}, map()) :: %Scenic.Graph{}

end
