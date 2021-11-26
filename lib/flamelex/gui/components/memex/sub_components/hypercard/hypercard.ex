defmodule Flamelex.GUI.Component.Memex.HyperCard do
    use Scenic.Component
    use Flamelex.ProjectAliases
    require Logger
    alias Flamelex.GUI.Component.Memex.{HyperCardTitle,
                                        HyperCardDateline}
    alias Flamelex.GUI.Component.Memex.HyperCard.{TagsBox, ToolBox, Body}

    
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


    # @default_height 300 # the minimum height that any HyperCard will be
    @inner_margin 15    # How much margin we put in between the border of the card, and text we want to render
    @font_size 24       # How big the standard font is (headers get scaled to this)

    @header_height 200

    @buffer_margin 50
    @titlebar_width 0.85
    @title_height 50

    @min_body_height 150    # Smallest height for any body, even 1 line of text

    @margin %{
        left: 15,
        top: 15,
        right: 15,
        bottom: 15
    }

    @dateline_height 40 #TODO  dont use hard-coded height for dateline
    @date_margin  10 #TODO dont do this either

    @left_margin 15     # How much left margin we leave in the HyperCard


    def validate(%{frame: %Frame{} = _f, tidbit: %Memex.TidBit{} = _t} = data) do
        Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
        {:ok, data}
    end

    def validate(_data) do
        {:error, "This component must be passed a %Frame{}"}
    end



    def init(scene, %{frame: frame, tidbit: tidbit} = params, opts) do
        Logger.debug "#{__MODULE__} initializing... title: #{inspect tidbit.title}"
        # Process.register(self(), __MODULE__) #TODO this is something that the old use Component system had - inbuilt process registration

        new_scene = scene
        |> assign(frame: frame)
        |> assign(tidbit: tidbit)
        # |> assign(config: %{
        #      margin_buf: params.margin_buf
        # })

        {:ok, new_scene, {:continue, :render_hypercard}}
    end

    def handle_continue(:render_hypercard, scene) do

        new_graph = render(scene.assigns)

        new_scene = scene
        |> assign(graph: new_graph)
        |> push_graph(new_graph)

        bounds = Scenic.Graph.bounds(new_graph)

        Flamelex.GUI.Component.LayoutList
        |> GenServer.cast({:component_height, scene.assigns.tidbit.title, bounds})
        
        {:noreply, new_scene}
    end


    def render(%{frame: %{dimensions: %{width: width, height: :flex}} = frame, tidbit: %Memex.TidBit{data: data} = tidbit}) do

        #TODO good idea: render each sub-component as a seperate graph,
        #                calculate their heights, then use Scenic.Graph.add_to
        #                to put them into the `:hypercard_itself` group
        #                -> Unfortunately, this doesn't work because Scenic
        #                doesn't seem to support "merging" 2 graphs, or
        #                if I return a graph (each component), no way to
        #                simply add that to another graph, as a sub-component


        # header_height = calc_header_height()
        body_height = calc_wrapped_text_height(%{frame: frame, text: data})

        full_hypercard_height = @header_height+body_height

        # %{x: x, y: y} = frame.top_left


        base_graph =
            Scenic.Graph.build()
            |> Scenic.Primitives.group(fn graph ->
                    graph
                    # render the background rectangle first, as our base layer, now that we know how high it needs to be
                    |> Scenic.Primitives.rect({width, full_hypercard_height},
                            id: :hypercard,
                            fill: :rebecca_purple)
                    # render just the background for the header section
                    |> Scenic.Primitives.rect({width, @header_height},
                            id: :hypercard,
                            fill: :deep_sky_blue)
                    |> render_title(%{
                            title: tidbit.title,
                            hypercard_frame: frame })
                    |> render_dateline(%{
                            hypercard_frame: frame })
                    |> render_tagsbox(%{
                            hypercard_frame: frame })
                    # |> render_toolbox(%{
                    #     hypercard_frame: frame })
                    |> render_body(%{
                            width: width,
                            header_height: @header_height,
                            data: data })
                end, [
                    #NOTE: We will scroll this pane around later on, and need to
                    #      add new TidBits to it with Modify
                    id: :hypercard_itself, # Scenic required we register groups/components with a name
                    translate: {frame.top_left.x+@buffer_margin, frame.top_left.y+@buffer_margin}
                ])
        
        # Scenic.Graph.add_to(:hypercard_itself, fn graph ->
            
        # end)
    end

    def render_body(graph, %{header_height: header_height, data: text, width: width}) when is_bitstring(text) do
        textbox_width = width-@margin.left-@margin.right
        {:ok, metrics} = TruetypeMetrics.load("./assets/fonts/IBMPlexMono-Regular.ttf") #TODO put this in the %Scene{} maybe?
        wrapped_text = FontMetrics.wrap(text, textbox_width, @font_size, metrics)

        graph
        |> Scenic.Primitives.text(wrapped_text,
            font: :ibm_plex_mono,
            font_size: @font_size,
            fill: :black,
            translate: {@margin.left, @margin.top+header_height+@font_size}) #TODO this should actually be, one line height
    end

    def render_body(graph, %{header_height: header_height, data: _data, width: width}) do
        graph
        |> Scenic.Primitives.text("UNABLE TO RENDER BODY",
            font: :ibm_plex_mono,
            font_size: @font_size,
            fill: :black,
            translate: {@margin.left, @margin.top+header_height+@font_size}) #TODO this should actually be, one line height
    end

    def render_title(graph, %{hypercard_frame: hyper_frame, title: title}) when is_bitstring(title) do
        title_area = {0.82*(hyper_frame.dimensions.width-(2*@buffer_margin)), @title_height} #TODO dont use hard-coded title_height
        title_font_size = 2*@font_size

        graph
        |> Scenic.Primitives.group(fn graph ->
            graph
            |> Scenic.Primitives.rect(title_area,
                     fill: :yellow,
                     scissor: title_area)
            |> Scenic.Primitives.text(title,
                     id: :hypercard_title_text,
                     font: :ibm_plex_mono,
                     # scissor: {frame.dimensions.width, frame.dimensions.height},
                     # translate: {frame.top_left.x+buffer, frame.top_left.y+font_size+(2*buffer)}, # text draws from bottom-left corner??
                    #  translate: {@inner_margin, title_font_size+@inner_margin}, # text draws from bottom-left corner??
                     translate: {0, title_font_size}, # text draws from bottom-left corner??
                     font_size: title_font_size,
                     fill: :black)
         end,
         id: {:hypercard, :title, title}, #TODO how do we register components/primitives
         translate: {@inner_margin, @inner_margin})
    end

    def render_dateline(graph, %{hypercard_frame: hyper_frame}) do
        dateline_area = {0.4*(hyper_frame.dimensions.width-(2*@buffer_margin)), @dateline_height}
        graph
        |> Scenic.Primitives.rect(dateline_area,
                fill: :grey,
                translate: {
                    @margin.left,
                    @margin.top+@title_height+@date_margin})
    end

    def render_tagsbox(graph, %{hypercard_frame: hyper_frame}) do
        #NOTE Same area as the title
        tagsbox_area = _title_area = {0.82*(hyper_frame.dimensions.width-(2*@buffer_margin)), @title_height} #TODO dont use hard-coded title_height

        graph
        |> Scenic.Primitives.rect(tagsbox_area,
                fill: :red,
                translate: {
                    @margin.left,
                    @margin.top+@title_height+@date_margin+@dateline_height+@date_margin})
    end

    #     def render(%{assigns: %{first_render?: true, frame: %Frame{} = frame, tidbit: t}} = scene) do
    #     new_graph =
    #         Scenic.Graph.build()
    #         |> Scenic.Primitives.rect({frame.dimensions.width, frame.dimensions.height},
    #                 id: :hypercard,
    #                 fill: :rebecca_purple,
    #                 translate: {
    #                     frame.top_left.x,
    #                     frame.top_left.y})
    #         |> HyperCardTitle.add_to_graph(%{
    #             frame: hypercard_title_frame(%{frame: scene.assigns.frame}), # calculate hypercard based of story_river
    #             # text: "Luke" },
    #             text: t.title },
    #             id: :hypercard_title)
    #             # scissor: hypercard_scissor(scene.assigns.frame))
    #         |> HyperCardDateline.add_to_graph(%{
    #                 frame: hypercard_dateline_frame(scene.assigns.frame) },
    #                 id: :hypercard_dateline)
    #         |> TagsBox.add_to_graph(%{
    #                 frame: hypercard_tagsbox_frame(scene.assigns.frame) },
    #                 id: :hypercard_tagsbox)
    #         |> ToolBox.add_to_graph(%{
    #             frame: hypercard_toolbox_frame(scene.assigns.frame) },
    #             id: :hypercard_toolbox)
    #         |> Scenic.Primitives.line(hypercard_line_spec(scene.assigns.frame), id: :hypercard_line, stroke: {2, :antique_white})
    #         |> Body.add_to_graph(%{
    #             frame: hypercard_body_frame(scene.assigns.frame),
    #             contents: t.data },
    #             id: :hypercard_body)

    #     scene
    #     |> assign(graph: new_graph)
    #     |> assign(first_render?: false)
    # end



    # def render(%{width: hypercard_width, text: pre_wrapped_text, scroll: scroll_coords}) do
    #     Scenic.Graph.build()
    #     |> Scenic.Primitives.group(fn graph ->
    #             graph
    #             |> Scenic.Primitives.rect({hypercard_width, @default_height},
    #                     id: :hypercard,
    #                     fill: :antique_white)
    #             |> Scenic.Primitives.text(pre_wrapped_text,
    #                     font: :ibm_plex_mono,
    #                     font_size: @font_size,
    #                     fill: :black,
    #                     translate: {@left_margin, @left_margin+@font_size}) #TODO this should actually be, one line height
    #         end, [
    #             #NOTE: We will scroll this pane around later on, and need to
    #             #      add new TidBits to it with Modify
    #             id: :hypercard_itself, #TODO Scenic required we register groups/components with a name
    #             translate: scroll_coords # We scroll just by moving the underlying Scenic.Group around
    #         ])
    # end

    #SIMPLOFY STEP 1 - only 1 init function

    # def init(scene, %{top_left: coords, width: w, tidbit: %{data: %{"filepath" => fp}} = t}, opts) do
    #         # def init(scene, %{frame: %Frame{top_left: _coords, dimensions: {_x, :flex}}}, opts) do #TODO make Frame accept :flex as params

    #     #NOTE: We need to find the body text here, so we can calculate
    #     #      the height of the body, so we know how big to make the background
    #     #      (a colored rectangle)

    #     # orig_text = File.read!(fp) |> IO.inspect(label: "ORIG")

    #     font_size = 24
    #     textbox_width = w-2*@left_margin

    #     {:ok, metrics} = TruetypeMetrics.load("./assets/fonts/IBMPlexMono-Regular.ttf")
    #     # wrapped_text = FontMetrics.wrap(orig_text, textbox_width, font_size, metrics)

    #     wrapped_text = "CANt RENDER BOFY"

    #     # new_graph =
    #     # Scenic.Graph.build()
    #     # |> Scenic.Primitives.group(fn graph ->
    #     #         graph
    #     #         |> Scenic.Primitives.rect({w, @default_height},
    #     #                 id: :hypercard,
    #     #                 fill: :antique_white)
    #     #         |> Scenic.Primitives.text(wrapped_text,
    #     #                 font: :ibm_plex_mono,
    #     #                 font_size: font_size,
    #     #                 fill: :black,
    #     #                 translate: {@left_margin, @left_margin+font_size}) #TODO this should actually be, one line height
    #     #     end, [
    #     #         #NOTE: We will scroll this pane around later on, and need to
    #     #         #      add new TidBits to it with Modify
    #     #         id: :hypercard_itself, # Scenic required we register groups/components with a name
    #     #         translate: coords
    #     #     ])

    #     new_scene = scene
    #     # |> assign(graph: new_graph)
    #     # |> push_graph(new_graph)
        
    #     {:ok, new_scene}
    # end

    # def init(scene, %{top_left: coords, width: w, tidbit: %{data: ""}}, opts) do
    #     Logger.debug "~~~~ Rendering a HyperCard with no body inside it !!!"

    #     # new_graph = Scenic.Graph.build()
    #     # |> Scenic.Primitives.rect({w, 300},
    #     #             id: :hypercard,
    #     #             fill: :chocolate,
    #     #             translate: coords)

    #     new_scene = scene
    #     # |> assign(graph: new_graph)
    #     # |> push_graph(new_graph)
        
    #     {:ok, new_scene}
    # end

    # def init(scene, %{top_left: coords, width: w, tidbit: %{data: data} = t}, opts) when is_bitstring(data) do
    # # def init(scene, %{frame: %Frame{top_left: _coords, dimensions: {_x, :flex}}}, opts) do #TODO make Frame accept :flex as params


    #     # new_graph = Scenic.Graph.build()
    #     # |> Scenic.Primitives.rect({w, 300},
    #     #             id: :hypercard,
    #     #             fill: :rebecca_purple,
    #     #             translate: coords)

    #         # |> Scenic.Primitives.text(wrapped_text, , fill: :black, translate: {@left_margin, 40})

    #     # new_graph =
    #     # Scenic.Graph.build()
    #     # |> Scenic.Primitives.group(fn graph ->
    #     #         graph
    #     #         |> Scenic.Primitives.rect({w, body_height},
    #     #                 id: :hypercard,
    #     #                 fill: :rebecca_purple)
    #     #                 # translate: coords)
    #     #         |> Scenic.Primitives.text(wrapped_text,
    #     #                 font: :ibm_plex_mono,
    #     #                 font_size: @font_size,
    #     #                 fill: :black,
    #     #                 translate: {@left_margin, @left_margin+@font_size}) #TODO this should actually be, one line height
    #     #     end, [
    #     #         #NOTE: We will scroll this pane around later on, and need to
    #     #         #      add new TidBits to it with Modify
    #     #         id: :hypercard_itself, # Scenic required we register groups/components with a name
    #     #         translate: coords
    #     #     ])

    #     new_scene = scene
    #     |> assign(graph: new_graph)
    #     |> push_graph(new_graph)

    #     full_bounds = text_bounds = Scenic.Graph.bounds(new_graph)

    #     Flamelex.GUI.Component.LayoutList
    #     |> GenServer.cast({:component_height, t.title, full_bounds})
        
    #     {:ok, new_scene}
    # end









    # next - this continue will be a better continue, with proper rendering support

    # def handle_continue(:update_story_river_with_our_height, state) do
    #     g = state.assigns.graph
    #     bounds = Scenic.Graph.bounds(g)
    #     IO.inspect bounds, label: "HOW HIGH"

    #     Flamelex.GUI.Component.LayoutList
    #     |> GenServer.cast({:component_height, state.assigns.tidbit.title, bounds})

    #     {:noreply, state}
    #   end

    # def re_render(scene) do
    #     GenServer.call(__MODULE__, {:re_render, scene})
    # end

    # def render_push_graph(scene) do
    #   new_scene = render(scene) # updates the graph
    #   new_scene |> push_graph(new_scene.assigns.graph) # pushes the changes
    # end



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


    # def handle_call({:re_render, %{frame: %Frame{} = f}}, _from, scene) do
    #     new_scene = scene
    #     |> assign(frame: f)
    #     |> render_push_graph()
        
    #     {:reply, :ok, new_scene}
    # end


    # def handle_cast({:new_tidbit, t}, scene) do

    #     new_scene = scene
    #     |> assign(tidbit: t)
    #     |> render_push_graph()

    #     {:noreply, new_scene}
    # end


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

    @doc """
    Calculates the render height of a bunch of text (after wrapping) for
    a given frame (including margins!)
    """
    def calc_wrapped_text_height(%{frame: frame, text: unwrapped_text}) when is_bitstring(unwrapped_text) do

        width = frame.dimensions.width
        textbox_width = width-@margin.left-@margin.right

        {:ok, metrics} = TruetypeMetrics.load("./assets/fonts/IBMPlexMono-Regular.ttf")
        wrapped_text = FontMetrics.wrap(unwrapped_text, textbox_width, @font_size, metrics)

        #NOTE: This tells us, how long the body will be - because in Scenic
        #      we take the top-left corner as the origin, the bottom of
        #      a bounding box is greater than the top. The total height
        #      is the bottom minus the top.
        {_left, top, _right, bottom} =
            Scenic.Graph.build()
            |> Scenic.Primitives.text(wrapped_text, font: :ibm_plex_mono, font_size: @font_size)
            |> Scenic.Graph.bounds()
        
        body_height = (bottom-top)+@margin.top+@margin.bottom

        if body_height <= @min_body_height do
            @min_body_height
        else
            body_height
        end
    end

    def calc_wrapped_text_height(_otherwise) do
        @min_body_height
    end
end