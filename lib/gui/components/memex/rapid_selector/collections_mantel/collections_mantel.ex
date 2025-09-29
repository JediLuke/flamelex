defmodule Memelex.GUI.Components.CollectionsMantel do
  use Scenic.Component
  # use Flamelex.ProjectAliases
  require Logger
  # alias ScenicWidgets.Core.Structs.Frame
  alias Widgex.Frame
  # alias Flamelex.GUI.Component.Memex
  # alias Flamelex.GUI.Component.RapidSelector.Reducer, as: RootReducer
  alias Flamelex.GUI.Component.CollectionsMantel

  def validate(%{frame: %Frame{} = _f, state: %CollectionsMantel.State{} = _state} = data) do
    Logger.debug("#{__MODULE__} accepted params: #{inspect(data)}")
    {:ok, data}
  end

  def init(init_scene, args, opts) do
    Logger.debug("#{__MODULE__} initializing...")

    # TODO get the full list of TidBits here (just Titles)

    theme =
      (opts[:theme] || Scenic.Primitive.Style.Theme.preset(:light))
      |> Scenic.Primitive.Style.Theme.normalize()

    [title_frame, side_nav_frame] = Widgex.Frame.v_split(args.frame, px: 120)

    init_graph =
      Scenic.Graph.build()
      |> Scenic.Primitives.group(
        fn graph ->
          graph
          |> render_collections_pane_title(title_frame)
          |> ScenicWidgets.SideNav.add_to_graph(
            %{
              frame: side_nav_frame,
              state: construct_collections_nav_tree(args.state)
            },
            id: {__MODULE__, :side_nav}
          )

          # |> render_background(dimensions: args.frame.size, color: theme.background)
          # |> render_personal_tile()
          # |> render_main_memex_search()
          # |> render_lower_pane(args)
        end,
        id: __MODULE__
        # translate: args.frame.pin
      )

    # Memelex.Utils.PubSub.subscribe()

    request_input(init_scene, [:cursor_scroll])

    new_scene =
      init_scene
      |> assign(graph: init_graph)
      |> assign(frame: args.frame)
      |> assign(state: args.state)
      |> assign(scroll: {0, 0})
      |> push_graph(init_graph)

    {:ok, new_scene}
  end

  def handle_input(
        {:cursor_scroll, {{_x_scroll, y_scroll} = delta_scroll, coords}},
        _context,
        scene
      ) do
    # TODO handle all this via a Reducer?? Or just keep it in the component??
    # Flamelex.Fluxus.action({Flamelex.GUI.Component.RapidSelector.Reducer, {:scroll, delta_scroll, __MODULE__}})

    fast_scroll = {0, 3 * y_scroll}
    # TODO cap scroll
    # new_cumulative_scroll =
    #     cap_position(scene, Scenic.Math.Vector2.add(scene.assigns.state.scroll, fast_scroll))
    new_cumulative_scroll = Scenic.Math.Vector2.add(scene.assigns.scroll, fast_scroll)

    new_graph =
      scene.assigns.graph
      |> Scenic.Graph.modify(
        __MODULE__,
        &Scenic.Primitives.update_opts(&1, translate: new_cumulative_scroll)
      )

    # new_state =
    #    scene.assigns.state
    #    |> put_in(scene.assigns., new_cumulative_scroll)

    new_scene =
      scene
      |> assign(graph: new_graph)
      #    |> assign(state: new_state)
      |> assign(scroll: new_cumulative_scroll)
      |> push_graph(new_graph)

    {:noreply, new_scene}
  end

  @font_size 40
  def render_collections_pane_title(graph, f) do
    graph
    # need to translate it down to account for the menubar height
    |> Scenic.Primitives.rect(f.size.box, fill: :cornflower_blue, stroke: {1, :ghost_white}, t: {0, 60})
    # |> ScenicWidgets.Markup.Header1.draw(frame, "Collections")
    |> Scenic.Primitives.text("Collections",
          font_size: @font_size,
          font: :ibm_plex_mono,
          # note we dont want to use Center here because that returns the centroid of the
          # frame in _absolute_ coordinates (taking into account frame pins & such)
          # whereas here we really just want to translate the text relative to the
          # outer graph, and that outer graph is already translated to the frame pin
          translate: {f.size.width / 2, (f.size.height - @font_size) / 2 + @font_size + 40}, # TODO magic number at thge end here
          # translate: {Widgex.Frame.center(f).x, (f.size.height - @font_size) / 2 + @font_size},
          text_align: :center,
          fill: :white
          # fill: Map.get(args, :color, @font_color)
        )
    |> Memelex.GUI.Components.IconButton.add_to_graph(
      %{
        frame: Frame.new(pin: {f.size.width / 2, f.size.height / 2 + 60 }, size: {22, 22}),
        icon: "ionicons/black_32/add-circle.png"
      },
      id: :new_collection
    )
  end

  def construct_collections_nav_tree(state) do
    # TODO note I don't think it can handle having more than one top-level right now....

    # TODO need to add indexes to each tidbit so we know what we clicked on (eventually)
    all_tidbits = Memelex.My.Wiki.all()

    all_leaves =
      Enum.map(all_tidbits, fn t -> {:leaf, t.title, [], fn -> Memelex.My.Wiki.open(t) end} end)

    # bepsi_tidbits = Memelex.My.Wiki.search(tagged: "bepsi")

    # bepsi_leaves =
    #   Enum.map(bepsi_tidbits, fn t -> {:leaf, t.title, [], fn -> Memelex.My.Wiki.open(t) end} end)

    # TODO most recent

    # TODO random selection

    collections = Enum.map(state.collections, fn
          %{data: %{items: []}} = c ->
            {:leaf, c.title, [], fn -> Memelex.My.Wiki.open(c) end}

          %{data: %{items: item_list}} = c ->
            # only go 1 level deep for now
            all_items =
              Enum.map(item_list,
                fn i_leaf ->
                  t = Memelex.My.Wiki.find_one!(%{"uuid" => i_leaf["uuid"]})
                  # t = %{title: "BERAU"}
                  {:leaf, t.title, [], fn -> Memelex.My.Wiki.open(%{"uuid" => i_leaf["uuid"]}) end}
                end)

            # REMINDER - when making a closed_node we can still pass it a click_fn you just need to ctrl-click it
            {:closed_node, c.title, [1], all_items, fn -> Memelex.My.Wiki.open(%{"uuid" => c.uuid}) end}
      end)

    # TODO untagged
    [
      {:closed_node, "all TidBits", [1], all_leaves}
      #   {:open_node, "tagged: `bepsi`", [2], bepsi_leaves}
    ] ++ collections

  end

  # def handle_info({:wiki_server, :memex_saved_to_disc}, scene) do
  #   # get child processes & cast update to SideNav

  #   new_tree = construct_collections_nav_tree()

  #   {:ok, [pid]} = Scenic.Scene.child(scene, {__MODULE__, :side_nav})
  #   GenServer.cast(pid, {:state_change, new_tree})

  #   {:noreply, scene}
  # end

  def handle_cast({:click, :new_collection}, scene) do
    Flamelex.Fluxus.action({Flamelex.GUI.Component.RapidSelector, :create_new_collection})
    {:noreply, scene}
  end

  def handle_info({:radix_state_change, _rx}, scene) do
    {:noreply, scene}
  end

  # def construct_file_tuples(root_dir, files) do
  #     files |> Enum.map(fn filename ->
  #        open_file_fn = fn -> Flamelex.API.Buffer.open(root_dir <> "/" <> filename) end
  #        {:leaf, t.title, open_file_fn}
  #     end)
  #  end

  # def construct_tuple_tree(nil) do
  #     []
  #  end

  #  def construct_tuple_tree(root_dir) when is_bitstring(root_dir) do

  #     files_and_dirs = File.ls!(root_dir) |> filter_ignored()
  #     {files, dirs} = split_files_and_directories(root_dir, files_and_dirs)

  #     sorted_dirs = sort_alphabetically(dirs)
  #     sorted_files = sort_alphabetically(files)

  #     dir_tuples = construct_dir_tuples(root_dir, sorted_dirs)
  #     file_tuples = construct_file_tuples(root_dir, sorted_files)

  #     dir_tuples ++ file_tuples # directories get put at the top
  #  end

  # def handle_info({:radix_state_change, %{memex: %{sidebar: new_sidebar_state}}}, %{assigns: %{state: current_state}} = scene)
  #     when current_state != new_sidebar_state do
  #         Logger.warning "#{__MODULE__} updating due to a change in the Memex.SideBar state..."
  #         raise "cant do this yet"
  #         {:noreply, scene}
  # end

  # #NOTE: if `sidebar_state` matches, here, then they are the same, and no change in state has occured
  # def handle_info({:radix_state_change, %{memex: %{sidebar: sidebar_state}}}, %{assigns: %{state: sidebar_state}} = scene) do
  #     Logger.debug "#{__MODULE__} ignoring a :radix_state_change, it didn't change the Memex.Sidebar..."
  #     {:noreply, scene}
  # end

  # def render_background(graph, dimensions: size, color: color) do
  #     graph |> Scenic.Primitives.rect(size, fill: color)
  # end

  # def render_lower_pane(graph, %{frame: %Frame{} = sidebar_frame,
  #                                state: %{active_tab: :ctrl_panel,
  #                                         search: %{active?: false}}}) do
  #     lower_pane_frame = calc_lower_pane_frame(sidebar_frame)

  #     graph
  #     |> Scenic.Primitives.group(fn graph ->
  #         graph
  #         |> render_background(dimensions: lower_pane_frame.size, color: :green)
  #         |> Scenic.Components.button("Open random TidBit", id: :open_random_tidbit_btn, translate: {15, 20})
  #         |> Scenic.Components.button("Create new TidBit", id: :create_new_tidbit_btn, translate: {15, 75})
  #     end,
  #     id: {__MODULE__, :ctrl_panel},
  #     translate: lower_pane_frame.pin)
  # end

  # def calc_lower_pane_frame(%{top_left: %{x: x, y: y}, dimensions: %{width: w, height: h}}) do
  #     lower_pane_ratio = 0.72 # lower pane takes up bottom 72% of the sidebafr
  #     Frame.new(
  #         top_left: {0, (1-lower_pane_ratio)*h}, # move down 6 tenths of the height
  #         dimensions: {w, lower_pane_ratio*h}) # take up 4 tenths of the height
  # end
end
