defmodule Flamelex.GUI.Component.Memex.HyperCard do
    use Scenic.Component
    use Flamelex.ProjectAliases
    require Logger
    alias Flamelex.GUI.Component.Memex.{HyperCardTitle,
                                        HyperCardDateline}
    alias Flamelex.GUI.Component.Memex.HyperCard.{TagsBox, ToolBox, Body}


    @default_height 300 # the minimum height that any HyperCard will be
    @inner_margin 15    # How much margin we put in between the border of the card, and text we want to render
    @font_size 24       # How big the standard font is (headers get scaled to this)

    @buffer_margin 4
    @titlebar_width 0.85
    @title_height 50

    @left_margin 15     # How much left margin we leave in the HyperCard

    def validate(%{frame: %Frame{} = _f, tidbit: %Memex.TidBit{} = _t} = data) do
        Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
        {:ok, data}
    end

    def validate(%{top_left: _tl, width: _w, tidbit: %Memex.TidBit{} = _t} = data) do
        Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
        {:ok, data}
    end

    def validate(_data) do
        {:error, "This component must be passed a %Frame{}"}
    end



    #TODO
    # - swap title & tabs sections
    # - work on title component that actually works how we want
    #       - scissored
    #       - scrollable (I guess only up/down, not side-side) - also show ... if we overflow our area
    #       - takes up 2 lines if necessary, just 1 if not
    # - work on body component displaying how we actually want it to work
    #       - wraps at correct width
    #       - renders infinitely long
    #       - only works for pure text, shows "NOT AVAILABLE" or whatever otherwise (centered ;)
    # - work on render nice tags & datetime sections
    # - work on taking us into edit more for a tidbit

    def render(%{width: hypercard_width, text: pre_wrapped_text, scroll: scroll_coords}) do
        Scenic.Graph.build()
        |> Scenic.Primitives.group(fn graph ->
                graph
                |> Scenic.Primitives.rect({hypercard_width, @default_height},
                        id: :hypercard,
                        fill: :antique_white)
                |> Scenic.Primitives.text(pre_wrapped_text,
                        font: :ibm_plex_mono,
                        font_size: @font_size,
                        fill: :black,
                        translate: {@left_margin, @left_margin+@font_size}) #TODO this should actually be, one line height
            end, [
                #NOTE: We will scroll this pane around later on, and need to
                #      add new TidBits to it with Modify
                id: :hypercard_itself, #TODO Scenic required we register groups/components with a name
                translate: scroll_coords # We scroll just by moving the underlying Scenic.Group around
            ])
    end

    #SIMPLOFY STEP 1 - only 1 init function

    def init(scene, %{top_left: coords, width: w, tidbit: %{data: %{"filepath" => fp}} = t}, opts) do
            # def init(scene, %{frame: %Frame{top_left: _coords, dimensions: {_x, :flex}}}, opts) do #TODO make Frame accept :flex as params

        #NOTE: We need to find the body text here, so we can calculate
        #      the height of the body, so we know how big to make the background
        #      (a colored rectangle)

        # orig_text = File.read!(fp) |> IO.inspect(label: "ORIG")

        font_size = 24
        textbox_width = w-2*@left_margin

        {:ok, metrics} = TruetypeMetrics.load("./assets/fonts/IBMPlexMono-Regular.ttf")
        # wrapped_text = FontMetrics.wrap(orig_text, textbox_width, font_size, metrics)

        wrapped_text = "CANt RENDER BOFY"

        # new_graph =
        # Scenic.Graph.build()
        # |> Scenic.Primitives.group(fn graph ->
        #         graph
        #         |> Scenic.Primitives.rect({w, @default_height},
        #                 id: :hypercard,
        #                 fill: :antique_white)
        #         |> Scenic.Primitives.text(wrapped_text,
        #                 font: :ibm_plex_mono,
        #                 font_size: font_size,
        #                 fill: :black,
        #                 translate: {@left_margin, @left_margin+font_size}) #TODO this should actually be, one line height
        #     end, [
        #         #NOTE: We will scroll this pane around later on, and need to
        #         #      add new TidBits to it with Modify
        #         id: :hypercard_itself, # Scenic required we register groups/components with a name
        #         translate: coords
        #     ])

        new_scene = scene
        # |> assign(graph: new_graph)
        # |> push_graph(new_graph)
        
        {:ok, new_scene}
    end

    def init(scene, %{top_left: coords, width: w, tidbit: %{data: ""}}, opts) do
        Logger.debug "~~~~ Rendering a HyperCard with no body inside it !!!"

        # new_graph = Scenic.Graph.build()
        # |> Scenic.Primitives.rect({w, 300},
        #             id: :hypercard,
        #             fill: :chocolate,
        #             translate: coords)

        new_scene = scene
        # |> assign(graph: new_graph)
        # |> push_graph(new_graph)
        
        {:ok, new_scene}
    end

    def init(scene, %{top_left: coords, width: w, tidbit: %{data: data} = t}, opts) when is_bitstring(data) do
    # def init(scene, %{frame: %Frame{top_left: _coords, dimensions: {_x, :flex}}}, opts) do #TODO make Frame accept :flex as params

        #NOTE: We need to find the body text here, so we can calculate
        #      the height of the body, so we know how big to make the background
        #      (a colored rectangle)
        textbox_width = w-2*@left_margin
        {:ok, metrics} = TruetypeMetrics.load("./assets/fonts/IBMPlexMono-Regular.ttf")
        wrapped_text = FontMetrics.wrap(t.data, textbox_width, @font_size, metrics)
        # |> IO.inspect(label: "TEXT")

        body_text_graph = Scenic.Graph.build()
        |> Scenic.Primitives.text(wrapped_text, font: :ibm_plex_mono, font_size: @font_size)
        
        #NOTE: This tells us, how long the body will be...
        {one, two, three, four} = text_bounds = Scenic.Graph.bounds(body_text_graph)
        # |> IO.inspect(label: "FINAL BOUNDS")

        body_height = four-two+(2*@left_margin) # just is

        # new_graph = Scenic.Graph.build()
        # |> Scenic.Primitives.rect({w, 300},
        #             id: :hypercard,
        #             fill: :rebecca_purple,
        #             translate: coords)

            # |> Scenic.Primitives.text(wrapped_text, , fill: :black, translate: {@left_margin, 40})

        new_graph =
        Scenic.Graph.build()
        |> Scenic.Primitives.group(fn graph ->
                graph
                |> Scenic.Primitives.rect({w, body_height},
                        id: :hypercard,
                        fill: :rebecca_purple)
                        # translate: coords)
                |> Scenic.Primitives.text(wrapped_text,
                        font: :ibm_plex_mono,
                        font_size: @font_size,
                        fill: :black,
                        translate: {@left_margin, @left_margin+@font_size}) #TODO this should actually be, one line height
            end, [
                #NOTE: We will scroll this pane around later on, and need to
                #      add new TidBits to it with Modify
                id: :hypercard_itself, # Scenic required we register groups/components with a name
                translate: coords
            ])

        new_scene = scene
        |> assign(graph: new_graph)
        |> push_graph(new_graph)

        full_bounds = text_bounds = Scenic.Graph.bounds(new_graph)

        Flamelex.GUI.Component.LayoutList
        |> GenServer.cast({:component_height, t.title, full_bounds})
        
        {:ok, new_scene}
    end

    def init(scene, params, opts) do
        Logger.debug "#{__MODULE__} initializing..."
        # Process.register(self(), __MODULE__) #TODO this is something that the old use Component system had - inbuilt process registration

        Logger.debug "HyperCard initializing for TidBit: #{inspect params.tidbit}"

        init_scene =
         %{scene|assigns: scene.assigns |> Map.merge(params)} # bring in the params into the scene, just put them straight into assigns
        |> assign(first_render?: true)
        |> render_push_graph()
    

        {:ok, init_scene, {:continue, :update_story_river_with_our_height}}
    end

    # next - this continue will be a better continue, with proper rendering support

    def handle_continue(:update_story_river_with_our_height, state) do
        g = state.assigns.graph
        bounds = Scenic.Graph.bounds(g)
        IO.inspect bounds, label: "HOW HIGH"

        Flamelex.GUI.Component.LayoutList
        |> GenServer.cast({:component_height, state.assigns.tidbit.title, bounds})

        {:noreply, state}
      end

    # def re_render(scene) do
    #     GenServer.call(__MODULE__, {:re_render, scene})
    # end

    def render_push_graph(scene) do
      new_scene = render(scene) # updates the graph
      new_scene |> push_graph(new_scene.assigns.graph) # pushes the changes
    end


    def render(%{assigns: %{first_render?: true, frame: %Frame{} = frame, tidbit: t}} = scene) do
        new_graph =
            Scenic.Graph.build()
            |> Scenic.Primitives.rect({frame.dimensions.width, frame.dimensions.height},
                    id: :hypercard,
                    fill: :rebecca_purple,
                    translate: {
                        frame.top_left.x,
                        frame.top_left.y})
            |> HyperCardTitle.add_to_graph(%{
                frame: hypercard_title_frame(%{frame: scene.assigns.frame}), # calculate hypercard based of story_river
                # text: "Luke" },
                text: t.title },
                id: :hypercard_title)
                # scissor: hypercard_scissor(scene.assigns.frame))
            |> HyperCardDateline.add_to_graph(%{
                    frame: hypercard_dateline_frame(scene.assigns.frame) },
                    id: :hypercard_dateline)
            |> TagsBox.add_to_graph(%{
                    frame: hypercard_tagsbox_frame(scene.assigns.frame) },
                    id: :hypercard_tagsbox)
            |> ToolBox.add_to_graph(%{
                frame: hypercard_toolbox_frame(scene.assigns.frame) },
                id: :hypercard_toolbox)
            |> Scenic.Primitives.line(hypercard_line_spec(scene.assigns.frame), id: :hypercard_line, stroke: {2, :antique_white})
            |> Body.add_to_graph(%{
                frame: hypercard_body_frame(scene.assigns.frame),
                contents: t.data },
                id: :hypercard_body)

        scene
        |> assign(graph: new_graph)
        |> assign(first_render?: false)
    end

    # def render(%{assigns: %{graph: %Scenic.Graph{} = graph, frame: frame, tidbit: t}} = scene) do



    #   GenServer.call(HyperCardTitle, {:update, %{tidbit: t}})
    # #   GenServer.call(:hypercard_dateline, {:hypercard_dateline, %{tidbit: t}})
    # #   GenServer.call(:hypercard_tagsbox, {:hypercard_tagsbox, %{tidbit: t}})
    # #   GenServer.call(:hypercard_toolbox, {:hypercard_toolbox, %{tidbit: t}})
    # #   GenServer.call(:hypercard_title, {:update, %{tidbit: t}})
    #   GenServer.call(Flamelex.GUI.Component.Memex.HyperCard.Body, {:update, %{tidbit: t}})
        
    #     # new_graph = graph
    #     # |> Scenic.Graph.delete(:hypercard)
    #     # |> Scenic.Graph.delete(:hypercard_title)
    #     # |> Scenic.Graph.delete(:hypercard_dateline)
    #     # |> Scenic.Graph.delete(:hypercard_tagsbox)
    #     # |> Scenic.Graph.delete(:hypercard_toolbox)
    #     # |> Scenic.Graph.delete(:hypercard_line)
    #     # |> Scenic.Graph.delete(:hypercard_body)
    #     # |> Scenic.Primitives.rect({frame.dimensions.width, frame.dimensions.height},
    #     #             id: :hypercard,
    #     #             fill: :rebecca_purple,
    #     #             translate: {
    #     #                 frame.top_left.x,
    #     #                 frame.top_left.y})
    #     # |> HyperCardTitle.add_to_graph(%{
    #     #     frame: hypercard_title_frame(scene.assigns.frame), # calculate hypercard based of story_river
    #     #     # text: "Luke" },
    #     #     text: t.title },
    #     #     id: :hypercard_title)
    #     # |> HyperCardDateline.add_to_graph(%{
    #     #         frame: hypercard_dateline_frame(scene.assigns.frame) },
    #     #         id: :hypercard_dateline)
    #     # |> TagsBox.add_to_graph(%{
    #     #             frame: hypercard_tagsbox_frame(scene.assigns.frame) },
    #     #             id: :hypercard_tagsbox)
    #     # |> ToolBox.add_to_graph(%{
    #     #         frame: hypercard_toolbox_frame(scene.assigns.frame) },
    #     #         id: :hypercard_toolbox)
    #     # |> Scenic.Primitives.line({{500, 300}, {1300, 300}}, id: :hypercard_line, stroke: {2, :black})
    #     # |> Body.add_to_graph(%{
    #     #     frame: hypercard_body_frame(scene.assigns.frame),
    #     #     contents: t.data },
    #     #     id: :hypercard_body)

    #     scene
    #     # |> assign(graph: new_graph)
    # end

    def hypercard_title_frame(
            %{frame: %{top_left: %{x: x, y: y}, dimensions: %{width: w, height: h}}},
            title_height \\ 50
    ) do
        Frame.new(top_left: {x+@buffer_margin, y+@buffer_margin},
                dimensions: {0.82*(w-(2*@buffer_margin)), @title_height})
    end

    def hypercard_scissor(%{top_left: %{x: x, y: y}, dimensions: %{width: w, height: h}}) do
        {@titlebar_width*(w-(2*@buffer_margin)), @title_height}
    end

    def hypercard_dateline_frame(%{top_left: %{x: x, y: y}, dimensions: %{width: w, height: h}}) do
        date_margin = 10
        dateline_height = 40
        Frame.new(top_left: {x+@buffer_margin, y+@buffer_margin+@title_height+date_margin},
                dimensions: {0.4*(w-(2*@buffer_margin)), dateline_height})

    end

    def hypercard_tagsbox_frame(%{top_left: %{x: x, y: y}, dimensions: %{width: w, height: h}}) do
        date_margin = 10
        Frame.new(top_left: {x+@buffer_margin, y+@buffer_margin+@title_height*2},
                dimensions: {@titlebar_width*(w-(2*@buffer_margin)), @title_height}) # same width & height as the title

    end

    def hypercard_toolbox_frame(%{top_left: %{x: x, y: y}, dimensions: %{width: w, height: h}}) do
        date_margin = 10
        title_width = @titlebar_width*(w-(2*@buffer_margin))
        Frame.new(top_left: {x+(2*@buffer_margin)+title_width, y+@buffer_margin},
                dimensions: {w-(@titlebar_width*(w-(2*@buffer_margin)))-3*@buffer_margin, 3*@title_height}) # same width & height as the title

    end
    
    def hypercard_line_spec(%{top_left: %{x: x, y: y}, dimensions: %{width: w, height: h}}) do
        line_y = 3*@title_height + 2*@buffer_margin
        {{x, y+line_y}, {x+w, y+line_y}}
    end
    
    def hypercard_body_frame(%{top_left: %{x: x, y: y}, dimensions: %{width: w, height: h}}) do
        line_y = 3*@title_height + 2*@buffer_margin
        Frame.new(top_left: {x+@buffer_margin, y+line_y+@buffer_margin},
                dimensions: {w-(2*@buffer_margin), h-(line_y+(2*@buffer_margin))}) # same width & height as the title

    end


    def handle_call({:re_render, %{frame: %Frame{} = f}}, _from, scene) do
        new_scene = scene
        |> assign(frame: f)
        |> render_push_graph()
        
        {:reply, :ok, new_scene}
    end


    def handle_cast({:new_tidbit, t}, scene) do

        new_scene = scene
        |> assign(tidbit: t)
        |> render_push_graph()

        {:noreply, new_scene}
    end


    #NOTE - you know, this is really the only thing that changes... all
    #       the above is Boilerplate

    # def render(scene) do
    #     scene |> Draw.background(:rebecca_purple)
    # end

    # def handle_call({:re_render, %{frame: %Frame{} = f}}, _from, scene) do
    #     new_scene = scene
    #     |> assign(frame: f)
    #     |> render_push_graph()
        
    #     {:reply, :ok, new_scene}
    # end
end