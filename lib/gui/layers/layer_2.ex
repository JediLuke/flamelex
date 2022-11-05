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
         frame: menubar_f,
         menu_map: calc_menu_map(radix_state),
         font: radix_state.menu_bar.font
      }
   end

   @impl Flamelex.GUI.Layer.Behaviour
   def render(layer_state) do
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
               {"temet nosce", &Flamelex.temet_nosce/0},
               {"show cmder", &Flamelex.API.Kommander.show/0},
               {"hide cmder", &Flamelex.API.Kommander.hide/0},
               {:sub_menu, "sub menu test", [
                  {"first item", fn -> IO.puts "clicked: `first item`" end},
                  {"second item", fn -> IO.puts "clicked: `second item`" end},
                  {:sub_menu, "sub sub menu", [
                     {"item [1,4,3,1]", fn -> IO.puts "clicked: `[1,4,3,1]`" end}
                  ]},
                  {"fourth item", fn -> IO.puts "clicked: `fourth item`" end},
                  {:sub_menu, "another sub menu", [
                        {:sub_menu, "deeply nested", [
                              {"deeply nested 1", fn -> IO.puts "clicked: `deeply nested 1`" end},
                              {:sub_menu, "deepest menu", [
                                 {"another button", fn -> IO.puts "clicked: `another button`" end},
                                 {"treasure", fn -> IO.puts "Congratulations! You found the treasure!" end},
                              ]},
                              {"deeply nested 2", fn -> IO.puts "deeply nested 2" end},
                              {"deeply nested 3", fn -> IO.puts "deeply nested 3" end},
                        ]}
                  ]},
                  {"last item", fn -> IO.puts "clicked: `last`" end}
               ]},
               # {:sub_menu, "arity/0 demo", ScenicWidgets.MenuBar.zero_arity_functions(ArityZeroDemo)}
               #DevTools
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
      # build the open-buffers sub-menu & open the buffer when we click on one
      #TODO if the buffer is unsaved, put an * at the end of it
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