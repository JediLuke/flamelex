defmodule Flamelex.GUI.Component.MenuBar do
    use Scenic.Component
    require Logger
    
    def validate(%{viewport: %Scenic.ViewPort{} = _vp, state: %{height: _h, menu_map: _m, font: _font}} = data) do
        {:ok, data}
    end

    def init(scene, args, opts) do

        init_graph = render(args)

        init_scene = scene
        |> assign(state: args.state)
        |> assign(graph: init_graph)
        |> push_graph(init_graph)

        # Flamelex.Utils.PubSub.subscribe(topic: :radix_state_change)

        {:ok, init_scene}
    end

    def render(%{viewport: %{size: {vp_width, _vp_height}}, state: menu_bar}) do

        %{metrics: metrics} = Flamelex.Fluxus.RadixStore.get().fonts.ibm_plex_mono

        Scenic.Graph.build()
        |> ScenicWidgets.MenuBar.add_to_graph( %{
                frame: ScenicWidgets.Core.Structs.Frame.new(
                    pin: {0, 0},
                    size: {vp_width, menu_bar.height}),
                menu_opts: menu_bar.menu_map,
                item_width: {:fixed, 180},
                font: menu_bar.font |> Map.merge(%{metrics: metrics}),
                sub_menu: menu_bar.sub_menu
        })
    end

    def handle_info({:radix_state_change, _new_radix_state}, scene) do
        # Logger.debug "#{__MODULE__} ignoring a :radix_state_change..."
        {:noreply, scene}
    end


end