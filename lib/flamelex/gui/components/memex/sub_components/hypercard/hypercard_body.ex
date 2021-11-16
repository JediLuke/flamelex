defmodule Flamelex.GUI.Component.Memex.HyperCard.Body do
    use Scenic.Component
    use Flamelex.ProjectAliases
    require Logger

    @component_id :hypercard_body
    @background_color :antique_white

    def validate(%{frame: %Frame{} = _f, contents: _c} = data) do
        Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
        {:ok, data}
    end

    def validate(_data) do
        {:error, "This component must be passed a %Frame{}"}
    end


    def init(scene, params, opts) do
        Logger.debug "#{__MODULE__} initializing..."
        Process.register(self(), __MODULE__) #TODO this is something that the old use Component system had - inbuilt process registration
        # Process.register(self(), :hypercard_body) #TODO this is something that the old use Component system had - inbuilt process registration

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


    def render(%{assigns: %{first_render?: true, frame: %Frame{} = frame, contents: body}} = scene) when is_bitstring(body) do
        text_buffer = 10
        font_size = 24
        text_left_margin = 15
        IO.puts "---------------RENDERING HYPERCARD BODY----------------"
        # new_graph =
        #     Scenic.Graph.build()
        #     |> Scenic.Primitives.group(fn graph ->
        #         graph
        #         |> Scenic.Primitives.rect({frame.dimensions.width, frame.dimensions.height},
        #                     fill: @background_color,
        #                     scissor: {frame.dimensions.width, frame.dimensions.height})
        #         |> Scenic.Primitives.text(body,
        #                     # id: :hypercard_body,
        #                     font: :ibm_plex_mono,
        #                     translate: {text_buffer, text_buffer+24},
        #                     font_size: font_size,
        #                     fill: :black)
        #    end,
        #    id: @component_id,
        #    translate: {frame.top_left.x, frame.top_left.y})

           {:ok, metrics} = TruetypeMetrics.load("./assets/fonts/IBMPlexMono-Regular.ttf")
        #    text_width = FontMetrics.width(state.text, font_size, metrics) 
        #    IO.inspect text_width, label: "WIdth222"
   
        IO.inspect body
        IO.puts "~~~~~~~~~~~~~~~~~~~"
           wrapped_text = FontMetrics.wrap(body, frame.dimensions.width-2*text_left_margin, font_size, metrics)
           IO.inspect wrapped_text
   
        #    wrapped_body = 

        new_graph =
           Scenic.Graph.build()
           |> Scenic.Primitives.group(fn graph ->
               graph
               |> Scenic.Primitives.rect({frame.dimensions.width, frame.dimensions.height},
                     scissor: {frame.dimensions.width, frame.dimensions.height},
                     fill: @background_color)
               |> Scenic.Primitives.text(wrapped_text, font: :ibm_plex_mono, font_size: font_size, fill: :black, translate: {text_left_margin, 40})
           end,
           translate: {frame.top_left.x, frame.top_left.y})

        scene
        |> assign(graph: new_graph)
        |> assign(first_render?: false)
    end


    def render(%{assigns: %{first_render?: true, frame: %Frame{} = frame, contents: %{"filepath" => _filepath}}} = scene) do
        # same as above but just ignore body for now
        text_buffer = 10
        new_graph =
            Scenic.Graph.build()
            |> Scenic.Primitives.group(fn graph ->
                graph
                |> Scenic.Primitives.rect({frame.dimensions.width, frame.dimensions.height},
                            id: @component_id,
                            fill: @background_color,
                            scissor: {frame.dimensions.width, frame.dimensions.height})
                |> Scenic.Primitives.text("UNABLE TO RENDER BODY",
                                # id: :hypercard_body,
                                font: :ibm_plex_mono,
                                translate: {text_buffer, text_buffer+24},
                                font_size: 24,
                                fill: :black)
           end,
           translate: {frame.top_left.x, frame.top_left.y})

        scene
        |> assign(graph: new_graph)
        |> assign(first_render?: false)
    end

    def render(%{assigns: %{graph: %Scenic.Graph{} = graph, frame: frame, contents: body}} = scene) when is_bitstring(body)  do
        # test_string = """
        # Alchemy (from Arabic: al-kīmiyā; from Ancient Greek: khumeía)[1] is an ancient branch of natural philosophy, a philosophical and protoscientific tradition that was historically practiced in China, India, the Muslim world, and Europe.[2] In its Western form, alchemy is first attested in a number of pseudepigraphical texts written in Greco-Roman Egypt during the first few centuries CE.
        # """
        text_buffer = 10
        {:ok, metrics} = TruetypeMetrics.load("./assets/fonts/IBMPlexMono-Regular.ttf")
        font_size = 24
        text_left_margin = 15
        wrapped_text = FontMetrics.wrap(body, frame.dimensions.width-2*text_left_margin, font_size, metrics)




        new_graph = graph
        |> Scenic.Graph.delete(@component_id)
        |> Scenic.Primitives.group(fn graph ->
            graph
            |> Scenic.Primitives.rect({frame.dimensions.width, frame.dimensions.height},
                    scissor: {frame.dimensions.width, frame.dimensions.height},
                    fill: @background_color)
            |> Scenic.Primitives.text(wrapped_text, font: :ibm_plex_mono, font_size: font_size, fill: :black, translate: {text_left_margin, 40})
        end,
        translate: {frame.top_left.x, frame.top_left.y})

        scene
        |> assign(graph: new_graph)
    end

    # not a text body
    def render(%{assigns: %{graph: %Scenic.Graph{} = graph, frame: frame, contents: %{"filepath" => _filepath}}} = scene) do
        text_buffer = 10
        font_size = 24
        text_left_margin = 15

        # IO.inspect filepath
        # body = File.read!(filepath)

        new_graph = graph
        |> Scenic.Graph.delete(@component_id)
        |> Scenic.Primitives.group(fn graph ->
                graph
                |> Scenic.Primitives.rect({frame.dimensions.width, frame.dimensions.height},
                            id: @component_id,
                            fill: @background_color,
                            scissor: {frame.dimensions.width, frame.dimensions.height})
                |> Scenic.Primitives.text("UNABLE TO RENDER BODY",
                                # id: :hypercard_body,
                                font: :ibm_plex_mono,
                                translate: {text_buffer, text_buffer+24},
                                font_size: 24,
                                fill: :black)
           end,
           translate: {frame.top_left.x, frame.top_left.y})

        scene
        |> assign(graph: new_graph)
    end


    def handle_call({:update, %{tidbit: t}}, _from, scene) do
        new_scene = scene
        |> assign(contents: t.data)
        |> render_push_graph()
        
        {:reply, :ok, new_scene}
    end


    def handle_call({:re_render, %{frame: %Frame{} = f}}, _from, scene) do
        new_scene = scene
        |> assign(frame: f)
        |> render_push_graph()
        
        {:reply, :ok, new_scene}
    end

end