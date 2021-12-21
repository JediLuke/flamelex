
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
        ic sub_menu


        graph
        # |> Draw.test_pattern(new_args)
        |> Scenic.Primitives.rect({width, height}, fill: :green)
    end
end
