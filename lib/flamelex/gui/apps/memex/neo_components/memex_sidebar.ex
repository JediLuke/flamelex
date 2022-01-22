defmodule Flamelex.GUI.Component.Memex.SideBar.New do
    use Scenic.Component
    use Flamelex.ProjectAliases
    require Logger
    alias Flamelex.GUI.Component.Memex

    @valid_sidebar_tabs [:open_tidbits, :ctrl_panel]

    def validate(%{frame: %Frame{} = _f, state: %{active_tab: tab}} = data) when tab in @valid_sidebar_tabs do
        Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
        {:ok, data}
    end

    def init(init_scene, args, opts) do
        Logger.debug "#{__MODULE__} initializing..."
    
        theme =
            (opts[:theme] || Scenic.Primitive.Style.Theme.preset(:light))
            |> Scenic.Primitive.Style.Theme.normalize()

        #TODO here - use a WindowArrangement of {:columns, [1,2,1]}
        init_graph = Scenic.Graph.build()
        |> Scenic.Primitives.group(fn graph ->
            graph
            |> render_background(dimensions: args.frame.size, color: theme.background)
            # |> render_personal_tile()
            # |> render_main_memex_search()
            |> render_lower_pane(args)
        end,
        id: __MODULE__,
        translate: args.frame.pin)

        Flamelex.Utils.PubSub.subscribe(topic: :radix_state_change)

        new_scene = init_scene
        |> assign(graph: init_graph)
        |> assign(frame: args.frame)
        |> assign(state: args.state)
        |> push_graph(init_graph)
  
        {:ok, new_scene}
    end

    def handle_event({:click, :open_random}, _from, scene) do
        # IO.inspect event
        #TODO get a random TidBit here
        IO.puts "CLICKED OPEN RANDOM - TODO, now call Flamelex.Fluxux.action({Memex.Reducer, :open_random})"
        {:noreply, scene}
    end

    def handle_event({:click, :create_new}, _from, scene) do
        # IO.inspect event
        IO.puts "CLICKED OPEN RANDOM - TODO, now call Flamelex.Fluxux.action({Memex.Reducer, :open_random})"
        {:noreply, scene}
    end

    def render_background(graph, dimensions: size, color: color) do
        graph |> Scenic.Primitives.rect(size, fill: color)
    end

    def render_lower_pane(graph, %{frame: %Frame{} = sidebar_frame,
                                   state: %{active_tab: :ctrl_panel,
                                            search: %{active?: false}}}) do
        lower_pane_frame = calc_lower_pane_frame(sidebar_frame)

        graph
        |> Scenic.Primitives.group(fn graph ->
            graph
            |> render_background(dimensions: lower_pane_frame.size, color: :green)
            |> Scenic.Components.button("Open random TidBit", id: :open_random, translate: {15, 20})
            |> Scenic.Components.button("Create new TidBit", id: :create_new, translate: {15, 75})
        end,
        id: {__MODULE__, :ctrl_panel},
        translate: lower_pane_frame.pin)
    end

    def calc_lower_pane_frame(%{top_left: %{x: x, y: y}, dimensions: %{width: w, height: h}}) do
        lower_pane_ratio = 0.72 # lower pane takes up bottom 72% of the sidebafr
        Frame.new(
            top_left: {0, (1-lower_pane_ratio)*h}, # move down 6 tenths of the height
            dimensions: {w, lower_pane_ratio*h}) # take up 4 tenths of the height
    end


end