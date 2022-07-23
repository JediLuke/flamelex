defmodule Flamelex.GUI.Component.MenuBar do
    use Scenic.Component
    require Logger
    
    def validate(%{
            viewport: %Scenic.ViewPort{} = _vp,
            state: %{height: _h, font: _font},
            gui: _gui
        } = data) do
                {:ok, data}
    end

    def init(scene, args, opts) do
        menu_map = Flamelex.Fluxus.RadixStore.get() |> calc_menu_map()
        init_graph = init_render(args |> Map.merge(%{menu_map: menu_map}))

        Process.register(self(), __MODULE__)

        init_scene = scene
        |> assign(state: args.state)
        |> assign(menu_map: menu_map)
        |> assign(graph: init_graph)
        |> push_graph(init_graph)

        Flamelex.Utils.PubSub.subscribe(topic: :radix_state_change)

        {:ok, init_scene}
    end

    def init_render(%{viewport: %{size: {vp_width, _vp_height}}, state: menu_bar, menu_map: _menu_map} = args) do

        menubar_font =
            Map.get(args.gui.fonts, menu_bar.font)
            |> Map.merge(%{size: menu_bar.font_size})

        Scenic.Graph.build()
        |> ScenicWidgets.MenuBar.add_to_graph( %{
                frame: ScenicWidgets.Core.Structs.Frame.new(
                    pin: {0, 0},
                    size: {vp_width, menu_bar.height}),
                menu_opts: args.menu_map,
                item_width: {:fixed, 180},
                font: menubar_font,
                sub_menu: menu_bar.sub_menu
        })
    end

    def handle_info({:radix_state_change, new_radix_state}, %{assigns: %{menu_map: current_menu_map}} = scene) do
        # Logger.debug "#{__MODULE__} ignoring a :radix_state_change..."
        #TODO here use cast to children, send new menubar options
        new_menu_map = calc_menu_map(new_radix_state)
        if new_menu_map != current_menu_map do
            IO.puts "NEW MENU MAP"
            cast_children(scene, {:put_menu_map, new_menu_map})
            {:noreply, scene |> assign(menu_map: new_menu_map)}
        else
            {:noreply, scene}
        end
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


    def calc_menu_map(radix_state) do
        [
          {:sub_menu, "Flamelex",
              [
                  {"temet nosce", &Flamelex.temet_nosce/0},
                   {"show cmder", &Flamelex.API.Kommander.show/0},
                   {"hide cmder", &Flamelex.API.Kommander.hide/0}
                  #DevTools
              ]},
          {:sub_menu, "Buffer", buffer_menu(radix_state)},
          {:sub_menu, "Memex",
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

    def buffer_menu(%{editor: %{buffers: []}} = _radix_state) do
        [
            {"new", &Flamelex.API.Buffer.new/0},
            {"save", &Flamelex.API.Buffer.save/0},
            {"close", &Flamelex.API.Buffer.close/0}
        ] 
    end

    def buffer_menu(%{editor: %{buffers: open_buffers}} = _radix_state) do
        # build the open-buffers sub-menu & open the nuffer when we click on one
        open_bufs_sub_menu = open_buffers
        |> Enum.map(fn %{id: {:buffer, name} = buf_id} ->
                #NOTE: Wrap this call in it's closure so it's a function of arity /0
                {name, fn -> Flamemex.API.Buffer.open(buf_id) end}
        end)

        [
            {:sub_menu, "open-buffers", open_bufs_sub_menu},
            {"new", &Flamelex.API.Buffer.new/0},
            #  {"list", &Flamelex.API.Buffer.new/0}, #TODO list should be an arrow-out menudown, that lists open buffers
            {"save", &Flamelex.API.Buffer.save/0},
            {"close", &Flamelex.API.Buffer.close/0}
        ] 
    end
end