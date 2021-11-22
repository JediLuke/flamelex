defmodule Flamelex.GUI.Component.Memex.HyperCard do
    use Scenic.Component
    use Flamelex.ProjectAliases
    require Logger
    alias Flamelex.GUI.Component.Memex.{HyperCardTitle,
                                        HyperCardDateline}
    alias Flamelex.GUI.Component.Memex.HyperCard.{TagsBox, ToolBox, Body}

    def validate(%{frame: %Frame{} = _f, tidbit: %Memex.TidBit{} = _t} = data) do
        Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
        {:ok, data}
    end

    def validate(_data) do
        {:error, "This component must be passed a %Frame{}"}
    end

    @buffer_margin 4
    @titlebar_width 0.85
    @title_height 50

    #TODO
    # - swap title & tabs sections
    # - work on title component that actually works how we want
    #       - scissored
    #       - scrollable (I guess only up/down, not side-side) - also show ... if we overflow our area
    #       - takes up 2 lines if necessary, just 1 if not
    # - work on body component displaying how we actually want it to work
    #       - wraps at correct width
    #       - renders infinitely long
    #       - only works for pure text, shows "NOT AVAILABLE" or whatever otherwise
    # - work on render nice tags & datetime sections
    # - work on taking us into edit more for a tidbit



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

    def handle_continue(:update_story_river_with_our_height, state) do
        g = state.assigns.graph
        bounds = Scenic.Graph.bounds(g)
        IO.inspect bounds, label: "HOW HIGH"

        Flamelex.GUI.Component.Memex.StoryRiver
        |> GenServer.cast({:component_height, state.assigns.tidbit.title, bounds})

        {:noreply, state}
      end

    def re_render(scene) do
        GenServer.call(__MODULE__, {:re_render, scene})
    end

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

    def render(%{assigns: %{graph: %Scenic.Graph{} = graph, frame: frame, tidbit: t}} = scene) do



      GenServer.call(HyperCardTitle, {:update, %{tidbit: t}})
    #   GenServer.call(:hypercard_dateline, {:hypercard_dateline, %{tidbit: t}})
    #   GenServer.call(:hypercard_tagsbox, {:hypercard_tagsbox, %{tidbit: t}})
    #   GenServer.call(:hypercard_toolbox, {:hypercard_toolbox, %{tidbit: t}})
    #   GenServer.call(:hypercard_title, {:update, %{tidbit: t}})
      GenServer.call(Flamelex.GUI.Component.Memex.HyperCard.Body, {:update, %{tidbit: t}})
        
        # new_graph = graph
        # |> Scenic.Graph.delete(:hypercard)
        # |> Scenic.Graph.delete(:hypercard_title)
        # |> Scenic.Graph.delete(:hypercard_dateline)
        # |> Scenic.Graph.delete(:hypercard_tagsbox)
        # |> Scenic.Graph.delete(:hypercard_toolbox)
        # |> Scenic.Graph.delete(:hypercard_line)
        # |> Scenic.Graph.delete(:hypercard_body)
        # |> Scenic.Primitives.rect({frame.dimensions.width, frame.dimensions.height},
        #             id: :hypercard,
        #             fill: :rebecca_purple,
        #             translate: {
        #                 frame.top_left.x,
        #                 frame.top_left.y})
        # |> HyperCardTitle.add_to_graph(%{
        #     frame: hypercard_title_frame(scene.assigns.frame), # calculate hypercard based of story_river
        #     # text: "Luke" },
        #     text: t.title },
        #     id: :hypercard_title)
        # |> HyperCardDateline.add_to_graph(%{
        #         frame: hypercard_dateline_frame(scene.assigns.frame) },
        #         id: :hypercard_dateline)
        # |> TagsBox.add_to_graph(%{
        #             frame: hypercard_tagsbox_frame(scene.assigns.frame) },
        #             id: :hypercard_tagsbox)
        # |> ToolBox.add_to_graph(%{
        #         frame: hypercard_toolbox_frame(scene.assigns.frame) },
        #         id: :hypercard_toolbox)
        # |> Scenic.Primitives.line({{500, 300}, {1300, 300}}, id: :hypercard_line, stroke: {2, :black})
        # |> Body.add_to_graph(%{
        #     frame: hypercard_body_frame(scene.assigns.frame),
        #     contents: t.data },
        #     id: :hypercard_body)

        scene
        # |> assign(graph: new_graph)
    end

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