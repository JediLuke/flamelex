defmodule Flamelex.GUI.ComponentBehaviour do #TODO this is only good for simple groups unfortunately, cant contain other components, because a pure render function cant handle the side-effects of processes being alive / holding state. Our only/best option would be kill each process & reboot it, but then we get timing issues cause processes dont die quick enough
  @moduledoc """
  GUI Components are defined here.
  """


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
      
      #NOTE: We must use the full component module names here, aliases
      #      won't work because this is a macro.

      # validate the incoming arguments when we mount a scene
      def validate(%{
            ref: _ref,                                  # Each component needs a ref. This will be used for addressing (sending the component messages)
            frame: %ScenicWidgets.Core.Structs.Frame{} = _f,  # Flamelex GUI components all have a defined %ScenicWidgets.Core.Structs.Frame{}
            state: _x} = data)                          # `state` is the holder for whatever data it is which defines the internal state of the component (usually a map)
        do
          {:ok, data}
      end

      #I think veryfiy got deprecated??
      #NOTE:
      # In our case, we always want a Component to be passed in a %ScenicWidgets.Core.Structs.Frame{}
      # so we don't need specific ones, each Component implements them
      # the same way. Also all components need a `ref`
      # def verify(%{
      #   ref: _r,                # the `ref` refers back to the Buffer that this GUI.Component is for, e.g. {:buffer, {:file, "README.md"}}
      #   frame: %ScenicWidgets.Core.Structs.Frame{} = _f    # the %ScenicWidgets.Core.Structs.Frame{} which defines this GUI.Component
      # } = params) do
      #   {:ok, params}
      # end
      # def verify(_else), do: :invalid_data
      # @impl Scenic.Component
      # def info(_data), do: ~s(Invalid data)



      @doc """
      Just like in Phoenix.LiveView, we mount our components onto an existing
      graph. In our case this is the same for all components though so we
      can abstract it out.
      """
      #TODO here, we need to pull out which are args, and which are opts
      #     I don't like sending a map AND a list, so I just accept a map :shrug:
      def mount(%Scenic.Graph{} = graph, %{
            ref: r,
            frame: %ScenicWidgets.Core.Structs.Frame{} = _f,
            state: _state
      } = args) do
        opts = [
          id: r     # we need to register the component with a name in Scenic, by passing it in as an option
        ]

        #REMINDER: `args` will in turn be passed into `validate/1, and if
        #          that succeeds, on to init/3 (as this is the way Scenic works)
        graph |> add_to_graph(args, opts) #REMINDER: Under the hood, this is calling Scenic.Component.add_to_graph/3
      end



      def init(scene, params, opts) do
        # Logger.debug "#{__MODULE__} initializing... #{inspect params}"

        params =
          #NOTE: This little trick is so that `custom_init_logic` is optional
          if function_exported?(__MODULE__, :custom_init_logic, 2) do
            apply(__MODULE__, :custom_init_logic, [scene, params])
          else
            params
          end

        #NOTE: To find a process later... e.g.
        #      ProcessRegistry.find!({:gui_component, Flamelex.GUI.Component.Memex.SecondSideBar, :second_sidebar})
        register_self(params)

        #TODO this could also subscribe to the channel for this id
        Flamelex.Utils.PubSub.subscribe(topic: :gui_event_bus)
        
        init_scene_first_stage = scene
        |> assign(ref: params.ref)
        |> assign(state: params.state)
        |> assign(frame: params.frame)
        
        new_graph = new_graph(init_scene_first_stage.assigns)

        init_scene = init_scene_first_stage
        |> assign(graph: new_graph)
        |> push_graph(new_graph)

        if function_exported?(__MODULE__, :request_input, 1) do
          apply(__MODULE__, :request_input, [init_scene])
        end

        {:ok, init_scene}
      end

      # This function builds our graph - render accepts this graph & adds
      # the group of primitives
        #TODO implement dev mode !! Each can be toggled with/without background!!
        #TODO also implement the optional frame footer rendering, or anything else
        # graph = render(params) 
        # |> Frame.draw_frame_footer(params)
      def new_graph(%{ref: ref, frame: frame, state: state} = args) do
        Scenic.Graph.build()
          |> Scenic.Primitives.group(fn init_graph ->
               init_graph |> render(args |> Map.merge(%{first_render?: true})) #REMINDER: render/1 has to be implemented by the modules "using" this behaviour, and that is the function being called here
          end,
        id: ref, #TODO do we need rego tag here?
        translate: {frame.top_left.x, frame.top_left.y})
      end

      def register_self(%{ref: :unregistered}) do
        :did_not_register
      end

      def register_self(%{ref: ref} = params) do
        tag = {:gui_component, _mod, _ref} =
          if function_exported?(__MODULE__, :rego_tag, 1) do
            apply(__MODULE__, :rego_tag, [params])
          else
            {:gui_component, __MODULE__, ref}
          end

        # Logger.debug "#{__MODULE__} registering as: #{inspect tag}"
        #TODO search for if the process is already registered, if it is, engage recovery procedure
        #Process.monitor(Process.whereis(KommandBuffer))
        Flamelex.Utils.ProcessRegistry.register(tag)
        {:rego_tag, tag}
      end

      def update(ref, new_state) do
        #TODO here we might need rego_tag/1
        Flamelex.Utils.ProcessRegistry.find(ref) |> GenServer.cast({:update, new_state})
      end

      def handle_cast({:update, new_state}, scene) do
        new_scene_first_stage = scene
        |> assign(state: new_state)

        new_graph = new_graph(new_scene_first_stage.assigns)
        
        new_scene = new_scene_first_stage
        |> assign(graph: new_graph)
        |> push_graph(new_graph)
  
        {:noreply, new_scene}
      end

      def handle_cast({:change_frame, new_frame}, scene) do
        raise "can't do this yet but shouldn't be too hard"
      end

    
    end # do quote 
  end # do defmacro

  
  #---------------------------------------------------------------------

  
  @doc """
  Each Component is represented internally at the highest level by the
  %ScenicWidgets.Core.Structs.Frame{} datastructure. This function takes in that Component definition
  and returns a %Scenic.Graph{} which can be drawn by Scenic.
  """
  @callback render(%Scenic.Graph{}, map()) :: %Scenic.Graph{}

  @doc """
  This behaviour gives a nice centralized & consistent method for
  initializing all components, but sometimes there is some special logic
  which needs to be done during a components init/2 function. In these
  cases, implement `custom_init_logic/1` - the args are whatever the args
  which were passed in during the call to `mount/1`, this function can
  then transform those args however it likes, before they are actually
  passed in to the start of the component initialization chain.

  One common example of where to use custom_init_logic/1 is when defining
  the initial state of a component.

  DON'T try to register components inside custom_init_logic!! If you want
  to customize how your component is registered, implement `rego_tag/1`
  and you can use the same params you would get here to define how you
  want the component to be registered (or if you want it to only have
  one consistent global name)

  This is an optional callback.
  """
  @callback custom_init_logic(map()) :: map()

  @doc """
  This function (which implemented) takes in a map of args and returns
  the rego tag for this component. This is useful when trying to find
  a component's pid.
  """
  @callback rego_tag(any()) :: any()

  @optional_callbacks custom_init_logic: 1, rego_tag: 1
end
