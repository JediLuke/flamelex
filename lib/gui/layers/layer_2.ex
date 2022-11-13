defmodule Flamelex.GUI.Layers.LayerTwo do
   # NOTE: Something in here has to be about layouts
   # NOTE: Layer 2 is the MenuBar component

   @behaviour Flamelex.GUI.Layer.Behaviour

   @impl Flamelex.GUI.Layer.Behaviour
   def calc_state(radix_state) do

      # calc the frame for the Menubar, we can choose to discard the other frames in the stack
      %{framestack: [menubar_f|_editor_f]} =
         ScenicWidgets.Core.Utils.FlexiFrame.calc(
            radix_state.gui.viewport,
            {:standard_rule, linemark: radix_state.menu_bar.height}
         )

      %{
         layer: 2,
         frame: menubar_f,
         menu_map: calc_menu_map(radix_state),
         font: radix_state.menu_bar.font
      }
   end

   @impl Flamelex.GUI.Layer.Behaviour
   def render(layer_state, _radix_state) do
      Scenic.Graph.build()
      |> ScenicWidgets.MenuBar.add_to_graph(%{
            frame: layer_state.frame,
            menu_map: layer_state.menu_map,
            font: layer_state.font
         },
         id: :menu_bar
      )
   end

   def calc_menu_map(radix_state) do
      [
         {:sub_menu, "Flamelex",
            [
               {:sub_menu, "Editor", [
                  {"toggle line nums", fn -> raise "no" end},
                  {"toggle file tray", fn -> raise "no" end},
                  {"toggle tab bar", fn -> raise "no" end},
                  {:sub_menu, "font", [
                  {:sub_menu, "primary font",
                     [
                     {"ibm plex mono", fn ->
                        Flamelex.Fluxus.RadixStore.get()
                        |> QuillEx.Reducers.RadixReducer.change_font(:ibm_plex_mono)
                        |> Flamelex.Fluxus.RadixStore.broadcast_update()
                     end},
                     {"roboto", fn ->
                        Flamelex.Fluxus.RadixStore.get()
                        |> QuillEx.Reducers.RadixReducer.change_font(:roboto)
                        |> Flamelex.Fluxus.RadixStore.broadcast_update()
                     end},
                     {"roboto mono", fn ->
                        Flamelex.Fluxus.RadixStore.get()
                        |> QuillEx.Reducers.RadixReducer.change_font(:roboto_mono)
                        |> Flamelex.Fluxus.RadixStore.broadcast_update()
                     end},
                     {"iosevka", fn ->
                        Flamelex.Fluxus.RadixStore.get()
                        |> QuillEx.Reducers.RadixReducer.change_font(:iosevka)
                        |> Flamelex.Fluxus.RadixStore.broadcast_update()
                     end},
                     {"source code pro", fn ->
                        Flamelex.Fluxus.RadixStore.get()
                        |> QuillEx.Reducers.RadixReducer.change_font(:source_code_pro)
                        |> Flamelex.Fluxus.RadixStore.broadcast_update()
                     end},
                     {"fira code", fn ->
                        Flamelex.Fluxus.RadixStore.get()
                        |> QuillEx.Reducers.RadixReducer.change_font(:fira_code)
                        |> Flamelex.Fluxus.RadixStore.broadcast_update()
                     end},
                     {"bitter", fn ->
                        Flamelex.Fluxus.RadixStore.get()
                        |> QuillEx.Reducers.RadixReducer.change_font(:bitter)
                        |> Flamelex.Fluxus.RadixStore.broadcast_update()
                     end}
                     ]},
                  {"make bigger", fn ->
                     Flamelex.Fluxus.RadixStore.get()
                     |> QuillEx.Reducers.RadixReducer.change_font_size(:increase)
                     |> Flamelex.Fluxus.RadixStore.broadcast_update()
                  end},
                  {"make smaller", fn ->
                     Flamelex.Fluxus.RadixStore.get()
                     |> QuillEx.Reducers.RadixReducer.change_font_size(:decrease)
                     |> Flamelex.Fluxus.RadixStore.broadcast_update()
                  end}
                  ]}
               ]},
               {:sub_menu, "Kommander", [
                  {"show", &Flamelex.API.Kommander.show/0},
                  {"hide", &Flamelex.API.Kommander.hide/0},
               ]},
               {:sub_menu, "DevTools", [
                  {"get radix state", fn -> Flamelex.API.DevTools.get_radix_state() |> IO.inspect() end},
                  {"temet nosce", &Flamelex.temet_nosce/0}
               ]}
            ]},
         {:sub_menu, "Buffer", buffer_menu(radix_state)},
         {:sub_menu, "Memex",
            [
               {"open", &Flamelex.API.Memex.open/0},
               {"close", &Flamelex.API.Memex.close/0},
               # random
               # journal
            ]},
         {:sub_menu, "API", ScenicWidgets.MenuBar.modules_and_zero_arity_functions("Elixir.Flamelex.API")},
         # {"Help", [
         # GettingStarted
         # {"About Flamelex", &Flamelex.API.Misc.makers_mark/0}]},
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
      # build the open-buffers sub-menu & open the buffer when we click on one
      #TODO if the buffer is unsaved, put an * at the end of it
      open_bufs_sub_menu = open_buffers
      |> Enum.map(fn %{id: {:buffer, name} = buf_id} ->
              #NOTE: Wrap this call in it's closure so it's a function of arity /0
              {name, fn -> Flamelex.API.Buffer.switch(buf_id) end}
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