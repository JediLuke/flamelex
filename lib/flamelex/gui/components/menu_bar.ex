defmodule Flamelex.GUI.Component.MenuBar do
    use Scenic.Component
    require Logger
    
    def validate(%{viewport: %Scenic.ViewPort{} = _vp, state: %{height: _h, menu_map_fn: _m, font: _font}} = data) do
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
                menu_opts: menu_bar.menu_map_fn.(),
                item_width: {:fixed, 180},
                font: menu_bar.font |> Map.merge(%{metrics: metrics}),
                sub_menu: menu_bar.sub_menu
        })
    end

    def handle_info({:radix_state_change, _new_radix_state}, scene) do
        # Logger.debug "#{__MODULE__} ignoring a :radix_state_change..."
        {:noreply, scene}
    end


      #TODO use this snippet to fill he MenuBar with Elixir functions
  # def get_dropdown_options() do
  #   :code.all_loaded()
  #   |> Enum.map( fn {module, _} -> module end )
  #   |> Enum.filter( fn mod -> String.starts_with?( "#{mod}", "Elixir.ScenicContribGraphingExamples.Scene") end)
  #   |> Enum.map( fn module ->
  #     {module.example_name(), module}
  #   end)
  # end


    def calc_menu_map do
        [
          {"Flamelex",
              [
                  {"temet nosce", &Flamelex.temet_nosce/0},
                   {"show cmder", &Flamelex.API.Kommander.show/0},
                   {"hide cmder", &Flamelex.API.Kommander.hide/0}
                  #DevTools
              ]},
          {"Buffer",
              [
                  {"new", &Flamelex.API.Buffer.new/0},
                  #  {"list", &Flamelex.API.Buffer.new/0}, #TODO list should be an arrow-out menudown, that lists open buffers
                  {"save", &Flamelex.API.Buffer.save/0},
                  {"close", &Flamelex.API.Buffer.close/0}
              ]},
          {"Memex",
              [
                  {"open", &Flamelex.API.Memex.open/0},
                  {"close", &Flamelex.API.Memex.close/0},
                  # random
                  # journal
              ]}
          # {"Help", [
          # GettingStarted
          # {"About QuillEx", &Flamelex.API.Misc.makers_mark/0}]},
        ]
      end
    
end