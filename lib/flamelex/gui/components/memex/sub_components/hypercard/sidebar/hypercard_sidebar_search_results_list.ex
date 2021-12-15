defmodule Flamelex.GUI.Component.Memex.HyperCard.Sidebar.SearchResultsList do
    use Scenic.Component
    use Flamelex.ProjectAliases
    require Logger


    def validate(%{frame: %Frame{} = _f} = data) do
        Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
        {:ok, data}
    end

    def validate(_data) do
        {:error, "This component must be passed a %Frame{}"}
    end


    # def init(scene, %{tidbit_results: tidbit_results, frame: frame} = params, opts) do
    def init(scene, %{tidbit_results: [], frame: frame} = params, opts) do
        Logger.debug "#{__MODULE__} initializing..."
        Process.register(self(), __MODULE__) #TODO this is something that the old use Component system had - inbuilt process registration

        new_graph = new_graph(frame, [])

        new_scene = scene
        |> assign(frame: params.frame)
        |> assign(graph: new_graph)
        |> push_graph(new_graph)

        {:ok, new_scene}
    end

    #TODO this should be "update state & redraw"
    def handle_cast({:update_results, r}, scene) do

        # new_graph = scene.assigns.graph
        #NOTE: unsatisfying perhaps, but since we can't call Scenic.Graph.modfy/3
        #      on a group, best we can do for now is just delete & replace it...
        # |> Scenic.Graph.modify(:tidbit_results, fn g -> &group(&1, )
        #         new_graph(scene.assigns.frame, r)
        # end)
        IO.puts "YEHAWY"

        # do we even need to delete it? Just replace it?
        # |> Scenic.graph.delete(:tidbit_results)

        new_graph = new_graph(scene.assigns.frame, r)


        new_scene = scene
        |> assign(graph: new_graph)
        |> push_graph(new_graph)

        {:noreply, new_scene}
    end

    #TODO maybe this has cracked it?? Every component is by default a group,
    #     with the name of that component as it's ID - we use Graph.modify
    #     to replace it with a new graph, which is calculated from a pure
    #     function of the component's state !!

    def new_graph(frame, []) do
        Scenic.Graph.build()
        |> Scenic.Primitives.group(fn init_graph ->
                init_graph
        end,
        id: :tidbit_results,
        translate: {frame.top_left.x, frame.top_left.y})
    end

    def new_graph(frame, results_list) when is_list(results_list) and length(results_list) >= 1 do
        IO.puts "MORE THAN ONE"
        Scenic.Graph.build()
        |> Scenic.Primitives.group(fn init_graph ->
                #TODO tage tidbit results, turn them into a new component "SingleResult" or someting which "uses" LinearLayoutItem
                {final_graph, _final_offset} =
                    results_list
                    |> Enum.reduce({init_graph, _initial_carry = 35}, fn title, {graph, carry} ->
                            this_graph_updated = graph
                            |> Flamelex.GUI.Component.Memex.HyperCard.Sidebar.SingleResult.mount(%{
                                 ref: :unregistered,
                                 frame: Frame.new(pin: {10, carry}, size: {frame.dimensions.width, 35}),
                                 state: %{text: title}
                            })
                            # |> Scenic.Primitives.text(title, t: {10, carry})

                            {this_graph_updated, carry+40}
                    end)
                final_graph
        end,
        id: :tidbit_results,
        translate: {frame.top_left.x, frame.top_left.y})
    end


    # |> Scenic.Primitives.rect({300, 300}, t: {300, 300}, fill: :red)
    # |> Scenic.Primitives.group(fn graph ->
    #     graph
    #     |> Scenic.Primitives.rect({frame.dimensions.width, frame.dimensions.height},
    #     id: @component_id,
    #     fill: @background_color,
    #     translate: {
    #         frame.top_left.x,
    #         frame.top_left.y})
    #     |> ResultsList.add_to_graph(%{
    #         tidbits: [],
    #         frame: results_list_frame(frame)
    #     })
    #     # |> Scenic.Primitives.rect({frame.dimensions.width, frame.dimensions.height},
    #     #     id: @component_id,
    #     #     fill: @background_color,
    #     #     translate: {
    #     #         frame.top_left.x,
    #     #         frame.top_left.y})
    #   end, [
    #      #NOTE: We will scroll this pane around later on, and need to
    #      #      add new TidBits to it with Modify
    #      id: :sidebar_search_results, # Scenic required we register groups/components with a name
    #   ])


end