defmodule Flamelex.GUI.Component.Memex.HyperCard do
    use Scenic.Component
    use Flamelex.ProjectAliases
    require Logger
    alias Flamelex.GUI.Component.Memex.{HyperCardTitle,
                                        HyperCardDateline}
    alias Flamelex.GUI.Component.Memex.HyperCard.{TagsBox, ToolBox, EditorsToolBox, Body}
    alias Flamelex.GUI.Component.Generic.NeoTextBox

    
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


    @inner_margin 15    # How much margin we put in between the border of the card, and text we want to render
    @font_size 24       # How big the standard font is (headers get scaled to this)

    @header_height 190

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

    @title_width_factor 0.92

    @dateline_height 40 #TODO  dont use hard-coded height for dateline
    @date_margin  10 #TODO dont do this either

    @left_margin 15     # How much left margin we leave in the HyperCard


    def validate(%{frame: %Frame{} = _f, tidbit: %Memelex.TidBit{} = _t} = data) do
        Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
        {:ok, data}
    end

    def validate(_data) do
        {:error, "This component must be passed a %Frame{}"}
    end



    def init(scene, %{frame: frame, tidbit: tidbit} = params, opts) do
        Logger.debug "#{__MODULE__} initializing... title: #{inspect tidbit.title}"

        # Process.register(self(), __MODULE__) #TODO this is something that the old use Component system had - inbuilt process registration
        Process.register(self, tidbit.title |> String.to_atom()) #TODO lol this is obviously bad but at least it works for now

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
        |> GenServer.cast({:component_height, scene.assigns.tidbit, bounds})
        
        {:noreply, new_scene}
    end

    def handle_cast(:edit_mode, scene) do
        Logger.debug "*********** EDIT MODE ***********"
        body_height = calc_wrapped_text_height(%{frame: scene.assigns.frame, text: scene.assigns.tidbit.data})
        full_hypercard_height = @header_height+body_height


        new_graph = scene.assigns.graph
        |> Scenic.Graph.delete(String.to_atom("hypercard_" <> scene.assigns.tidbit.title))
        |> Scenic.Primitives.group(fn graph ->
            graph
            # render the background rectangle first, as our base layer, now that we know how high it needs to be
            |> Scenic.Primitives.rect({scene.assigns.frame.dimensions.width, full_hypercard_height},
                    id: :hypercard,
                    fill: :orange)
            # render just the background for the header section
            # |> Scenic.Primitives.rect({width, @header_height},
            #         id: :hypercard,
            #         fill: :deep_sky_blue)
            # |> render_title(%{
            #         title: tidbit.title,
            #         hypercard_frame: frame })
            # |> render_dateline(%{
            #         hypercard_frame: frame })
            # |> render_tagsbox(%{
            #         hypercard_frame: frame })
            |> render_editors_toolbox(%{
                frame: scene.assigns.frame,
                tidbit: scene.assigns.tidbit })
            |> render_editors_body(%{
                    width: scene.assigns.frame.dimensions.width,
                    header_height: @header_height,
                    tidbit: scene.assigns.tidbit })
        end, [
            #NOTE: We will scroll this pane around later on, and need to
            #      add new TidBits to it with Modify
            # id: :hypercard_itself, # Scenic required we register groups/components with a name
            id: String.to_atom("hypercard_" <> scene.assigns.tidbit.title),
            translate: {scene.assigns.frame.top_left.x+@buffer_margin, scene.assigns.frame.top_left.y+@buffer_margin}
        ])

        new_scene = scene
        |> assign(graph: new_graph)
        |> push_graph(new_graph)

        {:noreply, new_scene}
    end

    def handle_cast(:exit_edit_mode, scene) do

        frame = scene.assigns.frame
        tidbit = scene.assigns.tidbit

        body_height = calc_wrapped_text_height(%{frame: frame, text: tidbit.data})
        full_hypercard_height = @header_height+body_height

        new_graph = scene.assigns.graph
        |> Scenic.Graph.delete(String.to_atom("hypercard_" <> scene.assigns.tidbit.title))
        |> Scenic.Primitives.group(fn graph ->
                    graph
                    # render the background rectangle first, as our base layer, now that we know how high it needs to be
                    |> Scenic.Primitives.rect({frame.dimensions.width, full_hypercard_height},
                            id: :hypercard,
                            fill: :rebecca_purple)
                    # render just the background for the header section
                    |> Scenic.Primitives.rect({frame.dimensions.width, @header_height},
                            id: :hypercard,
                            fill: :deep_sky_blue)
                    |> render_title(%{
                            title: tidbit.title,
                            hypercard_frame: frame })
                    |> render_dateline(%{
                            hypercard_frame: frame })
                    |> render_tagsbox(%{
                            hypercard_frame: frame })
                    |> render_toolbox(%{
                        hypercard_frame: frame,
                        title: tidbit.title })
                    |> render_body(%{
                            width: frame.dimensions.width,
                            header_height: @header_height,
                            data: tidbit.data })
        end, [
            #NOTE: We will scroll this pane around later on, and need to
            #      add new TidBits to it with Modify
            # id: :hypercard_itself, # Scenic required we register groups/components with a name
            id: String.to_atom("hypercard_" <> scene.assigns.tidbit.title),
            translate: {scene.assigns.frame.top_left.x+@buffer_margin, scene.assigns.frame.top_left.y+@buffer_margin}
        ])

        new_scene = scene
        |> assign(graph: new_graph)
        |> push_graph(new_graph)

        {:noreply, new_scene}
    end


    def render(%{frame: %{dimensions: %{width: width, height: :flex}} = frame, tidbit: %Memelex.TidBit{data: data} = tidbit}) do

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
                    |> render_toolbox(%{
                        hypercard_frame: frame,
                        title: tidbit.title })
                    |> render_body(%{
                            width: width,
                            header_height: @header_height,
                            data: data })
                end, [
                    #NOTE: We will scroll this pane around later on, and need to
                    #      add new TidBits to it with Modify
                    # id: :hypercard_itself, # Scenic required we register groups/components with a name
                    id: String.to_atom("hypercard_" <> tidbit.title),
                    translate: {frame.top_left.x+@buffer_margin, frame.top_left.y+@buffer_margin}
                ])
    end

    def render_editors_body(graph, %{tidbit: %{data: text} = tidbit, width: width} = args) when is_bitstring(text) do
        # textbox_width = width-@margin.left-@margin.right
        # {:ok, metrics} = TruetypeMetrics.load("./assets/fonts/IBMPlexMono-Regular.ttf") #TODO put this in the %Scene{} maybe?
        # wrapped_text = FontMetrics.wrap(text, textbox_width, @font_size, metrics)

        #TODO this now needs to be a textbox!!

        # graph
        # |> Scenic.Primitives.text(wrapped_text,
        #     font: :ibm_plex_mono,
        #     font_size: @font_size,
        #     fill: :black,
        #     translate: {@margin.left, @margin.top+header_height+@font_size}) #TODO this should actually be, one line height
        pin = {@margin.left, @margin.top+@header_height+@font_size}#TODO this should actually be, one line height

        state = args |> Map.merge(%{
            margin: @margin,
            header_height: @header_height,
            font_size: @font_size,
        })

        graph
        |> NeoTextBox.mount(%{
                ref: :neo_text_box,
                frame: Frame.new(pin: pin, size: {width, :flex}),
                state: state
            })
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
        title_width = @title_width_factor*(hyper_frame.dimensions.width-(2*@buffer_margin))
        title_area = {title_width, @title_height} #TODO dont use hard-coded title_height
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
        tagsbox_area = _title_area = {@title_width_factor*(hyper_frame.dimensions.width-(2*@buffer_margin)), @title_height} #TODO dont use hard-coded title_height

        graph
        |> Scenic.Primitives.rect(tagsbox_area,
                fill: :red,
                translate: {
                    @margin.left,
                    @margin.top+@title_height+@date_margin+@dateline_height+@date_margin})
    end

    def render_toolbox(graph, %{hypercard_frame: hyper_frame, title: title}) do
        title_width = @title_width_factor*(hyper_frame.dimensions.width-(2*@buffer_margin))

        toolbox_width = hyper_frame.dimensions.width-(@margin.left+title_width+@margin.left)-@margin.right
        toolbox_height = @title_height+@date_margin+@dateline_height+@date_margin+@title_height

        toolbox_top_left = {@margin.left+title_width+@margin.left, @margin.top}

        toolbox_frame = Frame.new(pin: toolbox_top_left, size: {toolbox_width, toolbox_height})

        graph
        # |> Scenic.Primitives.rect({toolbox_width, toolbox_height},
        #         fill: :sky_blue,
        #         translate: {
        #             @margin.left+title_width+@margin.left,
        #             @margin.top})
        |> ToolBox.add_to_graph(%{frame: toolbox_frame, title: title})
    end

    def render_editors_toolbox(graph, %{frame: hyper_frame, tidbit: tidbit}) do
        title_width = @title_width_factor*(hyper_frame.dimensions.width-(2*@buffer_margin))

        toolbox_width = hyper_frame.dimensions.width-(@margin.left+title_width+@margin.left)-@margin.right
        toolbox_height = @title_height+@date_margin+@dateline_height+@date_margin+@title_height

        toolbox_top_left = {@margin.left+title_width+@margin.left, @margin.top}

        toolbox_frame = Frame.new(pin: toolbox_top_left, size: {toolbox_width, toolbox_height})

        graph
        # |> Scenic.Primitives.rect({toolbox_width, toolbox_height},
        #         fill: :sky_blue,
        #         translate: {
        #             @margin.left+title_width+@margin.left,
        #             @margin.top})
        |> EditorsToolBox.add_to_graph(%{frame: toolbox_frame, tidbit: tidbit})
    end

    # def hypercard_toolbox_frame(%{top_left: %{x: x, y: y}, dimensions: %{width: w, height: h}}) do
    #     date_margin = 10
    #     title_width = @titlebar_width*(w-(2*@buffer_margin))
    #     Frame.new(top_left: {x+(2*@buffer_margin)+title_width, y+@buffer_margin},
    #             dimensions: {w-(@titlebar_width*(w-(2*@buffer_margin)))-3*@buffer_margin, 3*@title_height}) # same width & height as the title

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