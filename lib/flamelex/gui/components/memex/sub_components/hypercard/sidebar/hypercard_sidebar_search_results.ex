defmodule Flamelex.GUI.Component.Memex.HyperCard.Sidebar.SearchResults do
    use Scenic.Component
    use Flamelex.ProjectAliases
    require Logger
    alias Flamelex.GUI.Component.Memex.HyperCard.Sidebar.SearchResultsList

    @component_id :search_results
    @background_color :purple

    def validate(%{frame: %Frame{} = _f} = data) do
        Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
        {:ok, data}
    end

    def validate(_data) do
        {:error, "This component must be passed a %Frame{}"}
    end


    def init(scene, params, opts) do
        Logger.debug "#{__MODULE__} initializing..."
        Process.register(self(), __MODULE__) #TODO this is something that the old use Component system had - inbuilt process registration

        init_scene =
         %{scene|assigns: scene.assigns |> Map.merge(params)} # bring in the params into the scene, just put them straight into assigns
        |> assign(first_render?: true)
        |> render_push_graph()
    

        {:ok, init_scene}
    end

    def re_render(scene) do
        GenServer.call(__MODULE__, {:re_render, scene})
    end

    def render_push_graph(scene) do
      new_scene = render(scene) # updates the graph
      new_scene |> push_graph(new_scene.assigns.graph) # pushes the changes
    end


    def render(%{assigns: %{first_render?: true, frame: %Frame{} = frame}} = scene) do
        new_graph =
            Scenic.Graph.build()
            |> Scenic.Primitives.group(fn graph ->
                graph
                |> Scenic.Primitives.rect({frame.dimensions.width, frame.dimensions.height},
                id: @component_id,
                fill: @background_color,
                translate: {
                    frame.top_left.x,
                    frame.top_left.y})
                |> SearchResultsList.add_to_graph(%{
                    tidbit_results: [],
                    frame: frame
                })
                # |> Scenic.Primitives.rect({frame.dimensions.width, frame.dimensions.height},
                #     id: @component_id,
                #     fill: @background_color,
                #     translate: {
                #         frame.top_left.x,
                #         frame.top_left.y})
              end, [
                 #NOTE: We will scroll this pane around later on, and need to
                 #      add new TidBits to it with Modify
                 id: :sidebar_search_results, # Scenic required we register groups/components with a name
              ])


        scene
        |> assign(graph: new_graph)
        |> assign(first_render?: false)
    end

    # def render(%{assigns: %{graph: %Scenic.Graph{} = graph, frame: frame}} = scene) do
    #     new_graph = graph
    #     |> Scenic.Graph.delete(@component_id)
    #     |> Scenic.Primitives.rect({frame.dimensions.width-10, frame.dimensions.height-10},
    #                 id: @component_id,
    #                 fill: @background_color,
    #                 translate: {
    #                     frame.top_left.x+5,
    #                     frame.top_left.y+5})

    #     scene
    #     |> assign(graph: new_graph)
    # end



    # def handle_call({:re_render, %{frame: %Frame{} = f}}, _from, scene) do
    #     new_scene = scene
    #     |> assign(frame: f)
    #     |> render_push_graph()
        
    #     {:reply, :ok, new_scene}
    # end

    def handle_cast({:search, search_term}, scene) do
        IO.puts "Searching #{search_term} "
        r = Memex.My.Wiki.list(search_term)
            |> Enum.sort(& String.jaro_distance(search_term, &1.title) >= String.jaro_distance(search_term, &2.title))
        GenServer.cast(Flamelex.GUI.Component.Memex.HyperCard.Sidebar.SearchResultsList, {:update_results, r})
        {:noreply, scene}
    end

end