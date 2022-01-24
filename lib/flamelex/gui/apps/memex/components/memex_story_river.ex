defmodule Flamelex.GUI.Component.Memex.StoryRiver do
    use Scenic.Component
    use Flamelex.ProjectAliases
    require Logger
    # use ScenicWidgets.Macros.ImplementScrolling

    def validate(%{frame: %Frame{} = _f, state: %{
        open_tidbits: [],
        scroll: %{
          accumulator: {_x, _y},
          direction: :vertical,
          components: [],
          #acc_length: nil # this will get populated by the component, and will accumulate as TidBits get put in the StoryRiver 
    }}} = data) do
        Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
        {:ok, data}
    end


    def init(scene, args, opts) do
        Logger.debug "#{__MODULE__} initializing..."

        new_graph = Scenic.Graph.build()
        |> render_tidbits(args)

        Flamelex.Utils.PubSub.subscribe(topic: :radix_state_change)

        new_scene = scene
        |> assign(graph: new_graph)
        |> assign(frame: args.frame)
        |> assign(state: args.state)
        |> push_graph(new_graph)

        request_input(new_scene, [:cursor_scroll])

        {:ok, new_scene}
    end

    def handle_info({:radix_state_change, %{memex: %{story_river: new_story_river_state}}}, %{assigns: %{state: current_state}} = scene)
        when new_story_river_state != current_state do
            Logger.debug "#{__MODULE__} updating StoryRiver..."

            new_graph = Scenic.Graph.build()
            # |> ScenicWidgets.FrameBox.add_to_graph(%{frame: scene.assigns.frame, color: :pink})
            |> render_tidbits(%{state: new_story_river_state, frame: scene.assigns.frame})

            new_scene = scene
            |> assign(graph: new_graph)
            |> assign(state: new_story_river_state)
            |> push_graph(new_graph)
    
            {:noreply, new_scene}
    end

    #NOTE: If `story_river_state` binds on both variables here, then they are the same, no state-change occured and we can ignore this update
    def handle_info({:radix_state_change, %{memex: %{story_river: story_river_state}}}, %{assigns: %{state: story_river_state}} = scene) do
        IO.puts "NO CHNGE MYBE"
        {:noreply, scene}
    end

    def handle_input(
        {:cursor_scroll, {{_x_scroll, _y_scroll} = delta_scroll, coords}},
        _context,
        scene
        # %{
        #   assigns: %{
        #     state: %{
        #       scroll: %{
        #         accumulator: {_x, _y} = current_scroll,
        #         direction: :vertical
        #       }
        #     } = current_state
        #   }
        # } = scene
      ) do

        Flamelex.Fluxus.action({Flamelex.Fluxus.Reducers.Memex, {:scroll, delta_scroll, __MODULE__}})

        # IO.puts "YESYES"
        # fast_scroll = {0, 3 * y_scroll}

        # new_cumulative_scroll =
        #     cap_position(scene, Scenic.Math.Vector2.add(current_scroll, fast_scroll))

        # new_scroll_state =
        #     scene.assigns.state.scroll |> Map.put(:accumulator, new_cumulative_scroll)

        # new_state = %{current_state | scroll: new_scroll_state}

        # new_graph = scene.assigns.graph
        #   |> IO.inspect
        #   |> Scenic.Graph.modify(
        #     __MODULE__,
        #     &Scenic.Primitives.update_opts(&1, translate: new_state.scroll.accumulator)
        #   )
        #   |> IO.inspect

        # new_scene = scene
        #   |> assign(graph: new_graph)
        #   |> assign(state: new_state)
        #   |> push_graph(new_graph)

        {:noreply, scene}
    end

    def render_tidbits(graph, %{state: %{open_tidbits: []}} = _story_river_state) do
        graph |> Scenic.Graph.delete(__MODULE__)
    end

    def render_tidbits(graph, %{state: %{open_tidbits: [%Memelex.TidBit{} = tidbit], scroll: scroll}, frame: frame}) do
        new_graph = graph
        |> Scenic.Graph.delete(__MODULE__)
        |> Scenic.Primitives.group(fn graph ->
                graph
                |> Flamelex.GUI.Component.Memex.HyperCard.add_to_graph(%{
                        id: tidbit.uuid,
                        frame: hypercard_frame(frame),
                        state: tidbit
                })
            end, [
                id: __MODULE__,
                translate: scroll.accumulator
            ])
    end

    def hypercard_frame(%Frame{top_left: %{x: x, y: y}, dimensions: %{width: w, height: h}}) do
        bm = _buffer_margin = 50 # px
        Frame.new(top_left: {x+bm, y+bm}, dimensions: {w-(2*bm), {:flex_grow, %{min_height: 500}}})
    end

   
end