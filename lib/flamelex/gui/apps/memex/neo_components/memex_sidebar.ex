defmodule Flamelex.GUI.Component.Memex.SideBar.New do
    use Scenic.Component
    use Flamelex.ProjectAliases
    require Logger
    alias Flamelex.GUI.Component.Memex

    def validate(%{frame: %Frame{} = _f, state: %{active_tab: :open_tidbits}} = data) do
        Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
        {:ok, data}
    end

    def init(init_scene, args, opts) do
        Logger.debug "#{__MODULE__} initializing..."
    
        Flamelex.Utils.PubSub.subscribe(topic: :radix_state_change)

        theme =
            (opts[:theme] || Scenic.Primitive.Style.Theme.preset(:light))
            |> Scenic.Primitive.Style.Theme.normalize()

        init_graph = Scenic.Graph.build()
        |> Scenic.Primitives.group(fn graph ->
            graph
            # |> Scenic.Primitives.rect(args.frame.size, fill: theme.background)
            |> Scenic.Primitives.rect(args.frame.size, fill: :purple)
            # |> Scenic.Primitives.rect({frame.dimensions.width, frame.dimensions.height},
            #             id: @component_id,
            #             fill: @background_color,
            #             scissor: {frame.dimensions.width, frame.dimensions.height})
            # |> Scenic.Primitives.text("UNABLE TO RENDER BODY",
            #                 # id: :hypercard_body,
            #                 font: :ibm_plex_mono,
            #                 translate: {text_buffer, text_buffer+24},
            #                 font_size: 24,
            #                 fill: :black)
       end,
       id: __MODULE__,
       translate: args.frame.pin)

        #TODO here - use a WindowArrangement of {:columns, [1,2,1]}



        new_scene = init_scene
        |> assign(graph: init_graph)
        |> assign(frame: args.frame)
        |> assign(state: args.state)
        |> push_graph(init_graph)
  
        {:ok, new_scene}
    end


end