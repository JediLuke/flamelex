
defmodule Flamelex.GUI.Component.MenuBar.SubMenu do
    use Flamelex.GUI.ComponentBehaviour


    def render(graph, %{frame: %Frame{pin: pin, size: {width, :flex} = size} = frame} = args) do
        Logger.debug "#{__MODULE__} rendering..."
        # height = frame.dimensions.height #NOTE lmao this is :flex
        height=260
        ic width
        new_frame = Frame.new(pin: pin, size: {width, height})
        new_args = args |> Map.put(:frame, new_frame)

        {_top_levl, sub_menu} = args.state

        sub_menu = sub_menu |> Enum.into([])
        num_options = Enum.count(sub_menu)


        graph
        |> Scenic.Primitives.group(fn init_graph ->
            {final_graph, _final_offset} =
                sub_menu
                |> Enum.reduce({init_graph, _init_carry = 0}, fn {title, action}, {graph, carry} ->
                            this_graph_updated = graph
                            #TODO this nees to be its own component, like a search result, so we can detect hover events
                            # |> Scenic.Primitives.text(title, t: {10,carry})
                            |> Scenic.Components.button(title, t: {0, carry}, id: {title, action})

                            {this_graph_updated, carry+41}
                end)

            final_graph
        end,
        id: :sub_menu_actual,
        # translate: {frame.top_left.x, frame.top_left.y})
        )

        # |> Draw.test_pattern(new_args)
        # |> Scenic.Primitives.rect({width, height}, fill: :green)
    end

    def handle_event({:click, {_title, {mod, func, args}}}, _context, scene) do
        Kernel.apply(mod, func, args)
        {:noreply, scene}
    end


end
