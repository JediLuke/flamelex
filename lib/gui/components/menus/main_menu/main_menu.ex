defmodule Flamelex.GUI.Menus.MainMenu do
  @moduledoc false

  @doc """
  The top-level definition for the menu map in the Flamelex GUI.

  #TODO rename just to `menu_map` or `main_menu_map`
  """
  def calc_menu_map(radix_state) do
    base_menu_map =
      [
        flamelex_menu(),
        quillex_menu(radix_state),
        memex_menu(radix_state),
        help_menu()
      ]
      |> Enum.reject(&is_nil/1)
  end

  def flamelex_menu do
    {:sub_menu, "Flamelex",
     [
       devtools(),
       api_menu(),
       quit()
     ]}
  end

  #  {:sub_menu, "Editor",
  #   [
  #     {"toggle line nums", fn -> raise "no" end},
  #     {"toggle file tray", fn -> raise "no" end},
  #     {"toggle tab bar", fn -> raise "no" end}
  #     # font_sub_menu()
  #   ]},
  #  {:sub_menu, "Kommander",
  #   [
  #     {"show", &Flamelex.API.Kommander.show/0},
  #     {"hide", &Flamelex.API.Kommander.hide/0}
  #   ]},
  #  {:sub_menu, "Widgex",
  #   [
  #     {"open wdg-wkb", fn -> raise "no" end}
  #   ]},

  def quillex_menu(radix_state) do
    {:sub_menu, "Quillex", do_quillex_menu(radix_state)}
  end

  # hide the memex menu under certain conditions
  # def memex_menu(%{memex: %{active?: false}}), do: nil
  # def memex_menu(%{memex: %{env: nil}}), do: nil

  def memex_menu(
        %{
          # if we have an active memex, but no customizations to load
          memex: %{active?: true, env: %{name: env_name}}
        } = radix_state
      )
      when is_binary(env_name) do
    # TODO add random memex button

    base_menu = [
      # TODO if the current app is RapidSelector, it should be close, otherwise show open since basically this opens the RapidSelector even though it's called "memex"
      {"rapid selector",
       fn ->
         Flamelex.Fluxus.action({Flamelex.GUI.Component.RapidSelector, :open_memex})
       end},
      # {"close", &Flamelex.API.Diary.close/0},
      {"my TODOs", &Memelex.My.TODOs.show/0},
      {"my Agents", &Memelex.My.Agents.show/0},
      {:sub_menu, "my Projects",
       [
         {"all", &Memelex.My.Projects.show/0},
         {"Flamelex", &Flamelex.API.Projects.open_flamelex/0}
       ]},
      {:sub_menu, "my Calendar",
       [
         {"today",
          fn -> Memelex.My.Calendar.open(%{"date" => Date.utc_today(), "view" => "day"}) end},
         {"this week",
          fn -> Memelex.My.Calendar.open(%{"date" => Date.utc_today(), "view" => "week"}) end},
         {"this month",
          fn -> Memelex.My.Calendar.open(%{"date" => Date.utc_today(), "view" => "month"}) end}
       ]},
      {:sub_menu, "my Journal",
       [
         {"today", fn -> Memelex.My.Journal.today() end},
         {"yesterday", fn -> Memelex.My.Journal.yesterday() end},
         {"tomorrow", fn -> Memelex.My.Journal.tomorrow() end}
       ]}
    ]

    full_menu =
      base_menu
      |> maybe_add_agents_menu(radix_state)
      |> maybe_add_open_my_modz_button(radix_state)
      |> maybe_add_custom_menu(radix_state)

    {:sub_menu, "Memelex", full_menu}
  end

  def memex_menu(_radix_state) do
    memex_menu = [
      {"start new memex", fn -> Flamelex.Fluxus.action(:novum_memexi) end},
      {"load a memex", fn -> Flamelex.Fluxus.action(:memex_aperi) end}


      # {"novum memexi", fn -> raise "not yet" end},
      # {"memex aperi", fn ->
      #       Flamelex.Fluxus.action(:memex_aperi)
      #     end},
      # {:sub_menu, "library",
      #  [
      #    {"flamelex README", fn -> Flamelex.API.Buffer.open("README.md") end},
      #    {"Spinoza's ethics",
      #     fn ->
      #       Flamelex.API.Buffer.open(
      #         "/home/luke/workbench/flx/quillex/test/support/spinozas_ethics_p1.txt"
      #       )
      #     end},
      #    encyclopedia()
      #  ]}
    ]

    {:sub_menu, "Memelex", memex_menu}
  end

  def encyclopedia do
    {:sub_menu, "encyclopedia",
     [
       {:sub_menu, "A",
        [
          {"today's journal'", fn -> Memelex.My.Journal.today() end}
        ]},
       {:sub_menu, "B", []},
       {:sub_menu, "C", []},
       {:sub_menu, "D", []},
       {:sub_menu, "E", []}
     ]}
  end

  def api_menu do
    {:sub_menu, "API",
     Flamelex.GUI.Components.MenuBar.modules_and_zero_arity_functions("Elixir.Flamelex.API")}
  end

  def help_menu do
    {:sub_menu, "Help",
     [
       {"Open user manual", fn -> raise "you wish lol" end},
       {"Keybinding discovery", fn -> raise "you wish lol" end},
       {:sub_menu, "Getting Started",
        [
          {"Installation", fn -> IO.puts("This is the installation guide") end},
          {"Configuration", fn -> IO.puts("This is the configuration guide") end},
          {"Usage", fn -> IO.puts("This is the usage guide") end}
        ]},
       {:sub_menu, "About Flamelex",
        [
          # TODO should have popups here, not just print lines
          {"Version", fn -> IO.puts("Flamelex version ???") end},
          {"Authors", fn -> IO.puts("Flamelex was developed by JediLuke") end},
          {"License", fn -> IO.puts("Flamelex is licensed under the MIT License") end}
        ]}
     ]}
  end

  # TODO here, add save, maybe od a modal popup just to prove how cool we are!
  # Then implement ctrl+s as insert mode save (since I'm pretty sure it doesn't do anything in vim?)
  def do_quillex_menu(%{apps: %{qlx_wrap: %{buffers: []}}} = _radix_state) do

    [
      {"neo solutio", &Flamelex.API.Buffer.new/0}
    ]
  end

  def do_quillex_menu(radix_state) do
    [
      {"neo solutio", &Flamelex.API.Buffer.new/0},
      # {"raise error", fn -> raise "nothing works :(" end}
      open_buffers_menu(radix_state),
      # {"new", &Flamelex.API.Buffer.new/0},
      # #  {"list", &Flamelex.API.Buffer.new/0}, #TODO list should be an arrow-out menudown, that lists open buffers
      {"save", &Flamelex.API.Buffer.save/0}
      # {"close", &Flamelex.API.Buffer.close/0}
    ]
  end

  # def open_buffers_menu(%{apps: %{editor: %{buffers: open_buffers}}}) do
  #   raise "got open buffers #{inspect(open_buffers)}"
  # end

  def open_buffers_menu(%{apps: %{qlx_wrap: %{buffers: open_buffers}}})
      when length(open_buffers) >= 1 do
    # build the open-buffers sub-menu & open the buffer when we click on one
    # TODO if the buffer is unsaved, put an * at the end of it
    open_bufs_sub_menu =
      open_buffers
      |> Enum.map(fn buf_ref ->
        # NOTE: Wrap this call in it's closure so it's a function of arity /0
        {buf_ref.name, fn -> Flamelex.API.Buffer.switch(buf_ref) end}
        # {name, fn -> Quillex.API.Buffer.switch(buf_uuid) end}
        # {name, fn -> raise "NO - figure out what to do about quillex vs flamelex api buffer" end}
      end)

    {:sub_menu, "open buffers", open_bufs_sub_menu}
  end

  # def memex_menu(
  #       # when we have an active memex & a custom mod, check for custom menu
  #       %{
  #         memex: %{active?: true, env: %{name: env_name, env_modz_module: mod}}
  #       } = radix_state
  #     )
  #     when is_binary(env_name) and is_atom(mod) do
  #   {:sub_menu, "Memex", base_memex_menu} = do_memex_menu(radix_state)

  #   new_memex_menu =
  #     base_memex_menu
  #     # maybe add my_menu
  #     |> then(fn menu ->
  #       if Code.ensure_loaded?(mod) && function_exported?(mod, :my_menu, 1) do
  #         my_menu = mod.my_menu(radix_state)

  #         base_memex_menu
  #         |> List.insert_at(2, {env_name, my_menu})
  #       else
  #         menu
  #       end
  #     end)

  #   {:sub_menu, "Memex", new_memex_menu}
  # end

  # def memex_menu(
  #       %{
  #         # if we have an active memex, but no customizations to load
  #         memex: %{active?: true, env: %{name: env_name}}
  #       } = radix_state
  #     )
  #     when is_binary(env_name) do
  #   do_memex_menu(radix_state)
  # end

  # def memex_menu(_radix_state) do
  #   # if the memex is active, but there's no environment loaded
  #   {:sub_menu, "Memex",
  #    [
  #      {"new", fn -> IO.puts("CLicked new memex! THis doesn't do anything yet :)") end}
  #    ] ++ load_jedilukes()}
  # end

  # def check_module_function(module, function, arity) do
  #   if Code.ensure_loaded?(module) && function_exported?(module, function, arity) do
  #     IO.puts "The function #{function}/#{arity} is exported from the module #{module}."
  #   else
  #     IO.puts "The function #{function}/#{arity} is not exported from the module #{module}."
  #   end
  # end

  def maybe_add_agents_menu(memex_sub_menu, %{memex: %{env: %{env_modz_module: mod}}} = memex_env)
      when is_atom(mod) do
    memex_sub_menu
    |> then(fn menu ->
      if Code.ensure_loaded?(mod) && function_exported?(mod, :agents, 0) do
        menu
        |> List.insert_at(2, {"agents", fn -> IO.puts("this will eventually add agents!!") end})
      else
        menu
      end
    end)
  end

  # TODO my passwords !

  def maybe_add_open_my_modz_button(memex_sub_menu, %{
        memex: %{env: %{name: memex_name} = memex_env}
      })
      when is_binary(memex_name) do
    modz_file = Memelex.Environment.my_modz_filepath(memex_env)

    if not is_nil(modz_file) and File.exists?(modz_file) do
      memex_sub_menu
      |> List.insert_at(2, {"my Modz", fn -> Flamelex.API.Buffer.open(modz_file) end})
    else
      memex_sub_menu
    end
  end

  def maybe_add_open_my_modz_button(memex_sub_menu, _radix_state) do
    memex_sub_menu
  end

  def maybe_add_agents_menu(memex_sub_menu, _memex_env) do
    memex_sub_menu
  end

  def maybe_add_custom_menu(
        memex_sub_menu,
        %{
          memex: %{env: %{name: env_name, env_modz_module: mod} = memex_env}
        } = radix_state
      )
      when is_binary(env_name) and is_atom(mod) do
    memex_sub_menu
    |> then(fn menu ->
      if Code.ensure_loaded?(mod) && function_exported?(mod, :my_menu, 1) do
        my_menu = mod.my_menu(radix_state)

        memex_sub_menu
        |> List.insert_at(2, {env_name, my_menu})
      else
        menu
      end
    end)
  end

  def maybe_add_custom_menu(memex_sub_menu, _memex_env) do
    memex_sub_menu
  end

  # def do_memex_menu(:base_menu) do
  #   # TODO add random memex button
  #   # TODO we need to look in the environment, for if a specific fuinction is defined, inside their `my_modz.ex` module??

  #   base_menu =
  #     {:sub_menu, "Memex",
  #      [
  #        {"open", &Flamelex.API.Diary.open/0},
  #        {"close", &Flamelex.API.Diary.close/0},
  #        #  {"my_modz", fn -> Flamelex.API.Buffer.open(Memelex.Environment.my_modz_file()) end},
  #        {"journal", fn -> Memelex.My.Journal.today() end}
  #      ]}

  #   base_menu

  # end

  # def load_jedilukes do
  #   [
  #     {
  #       "load JediLuke",
  #       fn ->
  #         Memelex.deactivate()

  #         Memelex.load_env(%{
  #           name: "JediLuke",
  #           memex_directory: "/home/luke/memex/JediLuke"
  #         })
  #       end
  #     },
  #     {
  #       "load old JediLuke",
  #       fn ->
  #         Memelex.deactivate()

  #         Memelex.load_env(%{
  #           name: "old JediLuke",
  #           memex_directory: "/home/luke/backups/dubber_two/memex/JediLuke"
  #         })
  #       end
  #     },
  #     {
  #       "load really old JediLuke",
  #       # put us in the test environment / dream world
  #       fn ->
  #         Memelex.deactivate()

  #         Memelex.load_env(%{
  #           name: "old JediLuke",
  #           memex_directory: "/home/luke/backups/dubber_one/memex/JediLuke"
  #         })
  #       end
  #     }
  #   ]
  # end

  # TODO feature flags menus under DevTools

  def devtools do
    {:sub_menu, "DevTools",
     [
       {"temet nosce", &Flamelex.GUI.DevTools.temet_nosce/0},
       {"reboot ViewPort", fn -> Flamelex.GUI.DevTools.reboot_viewport() end},
       {
         "load Telaranrhiod",
         # put us in the test environment / dream world
         fn ->
           Memelex.deactivate()

           Memelex.load_env(%Memelex.Environment{
             name: "Telaranrhiod",
             memex_directory: "/home/luke/memex/Telaranrhiod"
           })
         end
       },
       {
         "load JediLuke",
         fn ->
           Memelex.deactivate()

           Memelex.load_env(%Memelex.Environment{
             name: "JediLuke",
             memex_directory: "/home/luke/memex/JediLuke"
           })
         end
       },
       widget_workbench(),
       alias_flx()
     ]}
  end

  # def font_sub_menu do
  #   {:sub_menu, "font",
  #    [
  #      {:sub_menu, "primary font",
  #       [
  #         {"ibm plex mono",
  #          fn ->
  #            Flamelex.Fluxus.RadixStore.get()
  #            |> QuillEx.Reducers.RadixReducer.change_font(:ibm_plex_mono)
  #            |> Flamelex.Fluxus.RadixStore.update()
  #          end},
  #         {"roboto",
  #          fn ->
  #            Flamelex.Fluxus.RadixStore.get()
  #            |> QuillEx.Reducers.RadixReducer.change_font(:roboto)
  #            |> Flamelex.Fluxus.RadixStore.update()
  #          end},
  #         {"roboto mono",
  #          fn ->
  #            Flamelex.Fluxus.RadixStore.get()
  #            |> QuillEx.Reducers.RadixReducer.change_font(:roboto_mono)
  #            |> Flamelex.Fluxus.RadixStore.update()
  #          end},
  #         {"iosevka",
  #          fn ->
  #            Flamelex.Fluxus.RadixStore.get()

  #            QuillEx.Reducers.RadixReducer.change_font(:iosevka)
  #            |> Flamelex.Fluxus.RadixStore.update()
  #          end},
  #         {"source code pro",
  #          fn ->
  #            Flamelex.Fluxus.RadixStore.get()
  #            |> QuillEx.Reducers.RadixReducer.change_font(:source_code_pro)
  #            |> Flamelex.Fluxus.RadixStore.update()
  #          end},
  #         {"fira code",
  #          fn ->
  #            Flamelex.Fluxus.RadixStore.get()
  #            |> QuillEx.Reducers.RadixReducer.change_font(:fira_code)
  #            |> Flamelex.Fluxus.RadixStore.update()
  #          end},
  #         {"bitter",
  #          fn ->
  #            Flamelex.Fluxus.RadixStore.get()
  #            |> QuillEx.Reducers.RadixReducer.change_font(:bitter)
  #            |> Flamelex.Fluxus.RadixStore.update()
  #          end}
  #       ]},
  #      {"make bigger",
  #       fn ->
  #         Flamelex.Fluxus.RadixStore.get()
  #         |> QuillEx.Reducers.RadixReducer.change_font_size(:increase)
  #         |> Flamelex.Fluxus.RadixStore.update()
  #       end},
  #      {"make smaller",
  #       fn ->
  #         Flamelex.Fluxus.RadixStore.get()
  #         |> QuillEx.Reducers.RadixReducer.change_font_size(:decrease)
  #         |> Flamelex.Fluxus.RadixStore.update()
  #       end}
  #    ]}
  # end

  # def open_agents do
  #   {"open agents",
  #    fn ->
  #      Flamelex.Fluxus.action({Flamelex.Fluxus.RadixReducer, :show_agents})
  #    end}
  # end

  def widget_workbench do
    {"widget wkb", &Flamelex.GUI.DevTools.open_widget_wkb/0}
  end

  def alias_flx do
    {"alias `flx` in shell", &Flamelex.Lib.Utils.TerminalIO.create_shell_alias/0}
  end

  def quit do
    {"Quit", &Flamelex.API.quit/0}
  end
end

# # TODO TopMenuMap
# defmodule Flamelex.GUI.TopMenuBar do
#   # TODO automatically add a .gitignore into each memex directory so it's impossible to accidentally commit the memex - anything except the my_modz.ex file
#   # note that although it can never be committed, we also make a my_secretz.ex file

#   def calc_menu_map(radix_state) do
#     # TODO add "help", "getting started", "about Flamelex" etc
#     base_menu_map =
#       [
#         flamelex_menu(),
#         buffer_menu(radix_state),
#         memex_menu(radix_state),
#         api_menu()
#       ]
#       |> Enum.reject(&is_nil/1)

#     # if radix_state.memex.active? do
#     #   # menu_map =

#     #   case calc_memex_menu(radix_state) do
#     #     [] ->
#     #       base_menu_map

#     #     memex_menu = {:sub_menu, "Memex", _full_menu} ->
#     #       base_menu_map |> List.insert_at(2, memex_menu)

#     #       # menu
#     #       # {:error, reason} ->
#     #       #   Logger.
#     #       #   base_menu_map
#     #   end

#     #   # base_menu_map |> List.insert_at(2, menu_map)
#     # else
#     #   base_menu_map
#     # end
#   end

#   def flamelex_menu do
#     {:sub_menu, "Flamelex",
#      [
#        {:sub_menu, "Editor",
#         [
#           {"toggle line nums", fn -> raise "no" end},
#           {"toggle file tray", fn -> raise "no" end},
#           {"toggle tab bar", fn -> raise "no" end},
#           font_sub_menu()
#         ]},
#        {:sub_menu, "Kommander",
#         [
#           {"show", &Flamelex.API.Kommander.show/0},
#           {"hide", &Flamelex.API.Kommander.hide/0}
#         ]},
#        {:sub_menu, "Widgex",
#         [
#           {"open wdg-wkb", fn -> raise "no" end}
#         ]},
#        devtools(),
#        open_agents(),
#        widget_workbench(),
#        re_source_shell(),
#        quit()
#      ]}
#   end

#   def buffer_menu(radix_state) do
#     {:sub_menu, "Buffer", do_buffer_menu(radix_state)}
#   end

#   def do_buffer_menu(%{editor: %{buffers: []}} = _radix_state) do
#     # what I currently call :sub_menu should be renamed :node,
#     # and these ones should have a tag like :leaf or :button
#     [
#       {"new", &Flamelex.API.Buffer.new/0},
#       {"save", &Flamelex.API.Buffer.save/0},
#       {"close", &Flamelex.API.Buffer.close/0}
#     ]
#   end

#   def do_buffer_menu(radix_state) do
#     [
#       do_open_buffers_menu(radix_state),
#       {"new", &Flamelex.API.Buffer.new/0},
#       #  {"list", &Flamelex.API.Buffer.new/0}, #TODO list should be an arrow-out menudown, that lists open buffers
#       {"save", &Flamelex.API.Buffer.save/0},
#       {"close", &Flamelex.API.Buffer.close/0}
#     ]
#   end

#   def do_open_buffers_menu(%{editor: %{buffers: open_buffers}}) when length(open_buffers) >= 1 do
#     # build the open-buffers sub-menu & open the buffer when we click on one
#     # TODO if the buffer is unsaved, put an * at the end of it
#     open_bufs_sub_menu =
#       open_buffers
#       |> Enum.map(fn %{id: {:buffer, name} = buf_id} ->
#         # NOTE: Wrap this call in it's closure so it's a function of arity /0
#         {name, fn -> Flamelex.API.Buffer.switch(buf_id) end}
#       end)

#     IO.puts("RECOMPUTING MENUBARRRRRR")
#     {:sub_menu, "open-buffers", open_bufs_sub_menu}
#   end

#   def api_menu do
#     {:sub_menu, "API",
#      ScenicWidgets.MenuBar.modules_and_zero_arity_functions("Elixir.Flamelex.API")}
#   end

#   # def memex_menu(
#   #       # when we have an active memex & a custom mod, check for custom menu
#   #       %{
#   #         memex: %{active?: true, env: %{name: env_name, env_modz_module: mod}}
#   #       } = radix_state
#   #     )
#   #     when is_binary(env_name) and is_atom(mod) do
#   #   {:sub_menu, "Memex", base_memex_menu} = do_memex_menu(radix_state)

#   #   new_memex_menu =
#   #     base_memex_menu
#   #     # maybe add my_menu
#   #     |> then(fn menu ->
#   #       if Code.ensure_loaded?(mod) && function_exported?(mod, :my_menu, 1) do
#   #         my_menu = mod.my_menu(radix_state)

#   #         base_memex_menu
#   #         |> List.insert_at(2, {env_name, my_menu})
#   #       else
#   #         menu
#   #       end
#   #     end)

#   #   {:sub_menu, "Memex", new_memex_menu}
#   # end

#   def memex_menu(%{memex: %{active?: false}}), do: nil
#   def memex_menu(%{memex: %{env: nil}}), do: nil

#   # def memex_menu(
#   #       %{
#   #         # if we have an active memex, but no customizations to load
#   #         memex: %{active?: true, env: %{name: env_name}}
#   #       } = radix_state
#   #     )
#   #     when is_binary(env_name) do
#   #   do_memex_menu(radix_state)
#   # end

#   # def memex_menu(_radix_state) do
#   #   # if the memex is active, but there's no environment loaded
#   #   {:sub_menu, "Memex",
#   #    [
#   #      {"new", fn -> IO.puts("CLicked new memex! THis doesn't do anything yet :)") end}
#   #    ] ++ load_jedilukes()}
#   # end

#   # def check_module_function(module, function, arity) do
#   #   if Code.ensure_loaded?(module) && function_exported?(module, function, arity) do
#   #     IO.puts "The function #{function}/#{arity} is exported from the module #{module}."
#   #   else
#   #     IO.puts "The function #{function}/#{arity} is not exported from the module #{module}."
#   #   end
#   # end

#   def memex_menu(
#         %{
#           # if we have an active memex, but no customizations to load
#           memex: %{active?: true, env: %{name: env_name}}
#         } = radix_state
#       )
#       when is_binary(env_name) do
#     # TODO add random memex button

#     base_menu = [
#       {"open", &Flamelex.API.Diary.open/0},
#       {"close", &Flamelex.API.Diary.close/0},
#       {"my_modz", fn -> raise "man we should have this!" end},
#       {"my TODOs", &Memelex.My.TODOs.show/0},
#       # {"my_modz", fn -> Flamelex.API.Buffer.open(Memelex.Environment.my_modz_file()) end},
#       {"journal", fn -> Memelex.My.Journal.today() end}
#     ]

#     full_menu =
#       base_menu
#       |> maybe_add_agents_menu(radix_state)
#       |> maybe_add_open_my_modz_button(radix_state)
#       |> maybe_add_custom_menu(radix_state)

#     {:sub_menu, "Memex", full_menu}
#   end

#   # def memex_menu(rdx_state) do
#   #   IO.puts("UNKNOWN RDX STATE #{inspect(rdx_state.memex)}")
#   #   nil
#   # end

#   def maybe_add_agents_menu(memex_sub_menu, %{memex: %{env: %{env_modz_module: mod}}} = memex_env)
#       when is_atom(mod) do
#     memex_sub_menu
#     |> then(fn menu ->
#       if Code.ensure_loaded?(mod) && function_exported?(mod, :agents, 0) do
#         menu
#         |> List.insert_at(2, {"agents", fn -> IO.puts("this will eventually add agents!!") end})
#       else
#         menu
#       end
#     end)
#   end

#   def maybe_add_open_my_modz_button(memex_sub_menu, %{
#         memex: %{env: %{name: memex_name} = memex_env}
#       })
#       when is_binary(memex_name) do
#     modz_file = Memelex.Environment.my_modz_filepath(memex_env)

#     if not is_nil(modz_file) and File.exists?(modz_file) do
#       memex_sub_menu
#       |> List.insert_at(2, {"my_modz", fn -> Flamelex.API.Buffer.open(modz_file) end})
#     else
#       memex_sub_menu
#     end
#   end

#   def maybe_add_open_my_modz_button(memex_sub_menu, _radix_state) do
#     memex_sub_menu
#   end

#   def maybe_add_agents_menu(memex_sub_menu, _memex_env) do
#     memex_sub_menu
#   end

#   def maybe_add_custom_menu(
#         memex_sub_menu,
#         %{
#           memex: %{env: %{name: env_name, env_modz_module: mod} = memex_env}
#         } = radix_state
#       )
#       when is_binary(env_name) and is_atom(mod) do
#     memex_sub_menu
#     |> then(fn menu ->
#       if Code.ensure_loaded?(mod) && function_exported?(mod, :my_menu, 1) do
#         my_menu = mod.my_menu(radix_state)

#         memex_sub_menu
#         |> List.insert_at(2, {env_name, my_menu})
#       else
#         menu
#       end
#     end)
#   end

#   def maybe_add_custom_menu(memex_sub_menu, _memex_env) do
#     memex_sub_menu
#   end

#   # def do_memex_menu(:base_menu) do
#   #   # TODO add random memex button
#   #   # TODO we need to look in the environment, for if a specific fuinction is defined, inside their `my_modz.ex` module??

#   #   base_menu =
#   #     {:sub_menu, "Memex",
#   #      [
#   #        {"open", &Flamelex.API.Diary.open/0},
#   #        {"close", &Flamelex.API.Diary.close/0},
#   #        #  {"my_modz", fn -> Flamelex.API.Buffer.open(Memelex.Environment.my_modz_file()) end},
#   #        {"journal", fn -> Memelex.My.Journal.today() end}
#   #      ]}

#   #   base_menu

#   # end

#   # def load_jedilukes do
#   #   [
#   #     {
#   #       "load JediLuke",
#   #       fn ->
#   #         Memelex.deactivate()

#   #         Memelex.load_env(%{
#   #           name: "JediLuke",
#   #           memex_directory: "/home/luke/memex/JediLuke"
#   #         })
#   #       end
#   #     },
#   #     {
#   #       "load old JediLuke",
#   #       fn ->
#   #         Memelex.deactivate()

#   #         Memelex.load_env(%{
#   #           name: "old JediLuke",
#   #           memex_directory: "/home/luke/backups/dubber_two/memex/JediLuke"
#   #         })
#   #       end
#   #     },
#   #     {
#   #       "load really old JediLuke",
#   #       # put us in the test environment / dream world
#   #       fn ->
#   #         Memelex.deactivate()

#   #         Memelex.load_env(%{
#   #           name: "old JediLuke",
#   #           memex_directory: "/home/luke/backups/dubber_one/memex/JediLuke"
#   #         })
#   #       end
#   #     }
#   #   ]
#   # end

#   def devtools do
#     {:sub_menu, "DevTools",
#      [
#        {"get radix state", fn -> Flamelex.API.DevTools.get_radix_state() end},
#        {
#          "load Telaranrhiod",
#          # put us in the test environment / dream world
#          fn ->
#            Memelex.deactivate()

#            Memelex.load_env(%Memelex.Environment{
#              name: "Telaranrhiod",
#              memex_directory: "/home/luke/memex/Telaranrhiod"
#            })
#          end
#        },
#        {"temet nosce", &Flamelex.temet_nosce/0},
#        {
#          "load JediLuke",
#          fn ->
#            Memelex.deactivate()

#            Memelex.load_env(%Memelex.Environment{
#              name: "JediLuke",
#              memex_directory: "/home/luke/memex/JediLuke"
#            })
#          end
#        }
#      ]}
#   end

#   def font_sub_menu do
#     {:sub_menu, "font",
#      [
#        {:sub_menu, "primary font",
#         [
#           {"ibm plex mono",
#            fn ->
#              Flamelex.Fluxus.RadixStore.get()
#              |> QuillEx.Reducers.RadixReducer.change_font(:ibm_plex_mono)
#              |> Flamelex.Fluxus.RadixStore.update()
#            end},
#           {"roboto",
#            fn ->
#              Flamelex.Fluxus.RadixStore.get()
#              |> QuillEx.Reducers.RadixReducer.change_font(:roboto)
#              |> Flamelex.Fluxus.RadixStore.update()
#            end},
#           {"roboto mono",
#            fn ->
#              Flamelex.Fluxus.RadixStore.get()
#              |> QuillEx.Reducers.RadixReducer.change_font(:roboto_mono)
#              |> Flamelex.Fluxus.RadixStore.update()
#            end},
#           {"iosevka",
#            fn ->
#              Flamelex.Fluxus.RadixStore.get()

#              QuillEx.Reducers.RadixReducer.change_font(:iosevka)
#              |> Flamelex.Fluxus.RadixStore.update()
#            end},
#           {"source code pro",
#            fn ->
#              Flamelex.Fluxus.RadixStore.get()
#              |> QuillEx.Reducers.RadixReducer.change_font(:source_code_pro)
#              |> Flamelex.Fluxus.RadixStore.update()
#            end},
#           {"fira code",
#            fn ->
#              Flamelex.Fluxus.RadixStore.get()
#              |> QuillEx.Reducers.RadixReducer.change_font(:fira_code)
#              |> Flamelex.Fluxus.RadixStore.update()
#            end},
#           {"bitter",
#            fn ->
#              Flamelex.Fluxus.RadixStore.get()
#              |> QuillEx.Reducers.RadixReducer.change_font(:bitter)
#              |> Flamelex.Fluxus.RadixStore.update()
#            end}
#         ]},
#        {"make bigger",
#         fn ->
#           Flamelex.Fluxus.RadixStore.get()
#           |> QuillEx.Reducers.RadixReducer.change_font_size(:increase)
#           |> Flamelex.Fluxus.RadixStore.update()
#         end},
#        {"make smaller",
#         fn ->
#           Flamelex.Fluxus.RadixStore.get()
#           |> QuillEx.Reducers.RadixReducer.change_font_size(:decrease)
#           |> Flamelex.Fluxus.RadixStore.update()
#         end}
#      ]}
#   end

#   def widget_workbench do
#     {"widget wkb", &Flamelex.DevTools.widget_workbench/0}
#   end

#   def re_source_shell do
#     {"re_source_shell", &Flamelex.Lib.Utils.TerminalIO.create_shell_alias/0}
#   end

#   def quit do
#     {"quit", &Flamelex.API.quit/0}
#   end
# end
