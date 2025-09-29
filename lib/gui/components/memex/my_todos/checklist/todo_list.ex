defmodule Flamelex.GUI.Component.TODOlist do
  @moduledoc """
  A GUI component for managing my TODO list.
  """
  use Scenic.Component
  alias Widgex.Frame
  alias Flamelex.GUI.Components.NeoHyperCard
  alias Flamelex.GUI.Component.TODOlist
  alias Flamelex.GUI.Component.TODOlist.State

  # TODO accept `selected` as an argument & change background opr whjatever when it's selected
  # def validate(%{frame: %Frame{} = _f, state: %{items: _i}} = data) do
  def validate(
        %{
          frame: %Frame{} = _f
        } = data
      ) do
    # Logger.debug "#{__MODULE__} accepted params: #{inspect data}"
    # new_state = Map.merge(state, %{scroll: {0, 0}})
    # {:ok, assign(data, state: new_state)}
    # {:ok, %{data | state: new_state}}
    {:ok, data}
  end

  # def get_current_todo do
  #   GenServer.call(__MODULE__, :get_selected_todo)
  # end

  def init(scene, %{frame: %Frame{} = f}, opts) do
    state = Flamelex.Fluxus.RadixStore.get().apps.todo_list

    # Add semantic information for the TODO list component
    semantic_info = %{
      type: :todo_list,
      role: :application,
      label: "My TODOs",
      description: "Personal task and TODO management",
      state: %{
        item_count: length(state.list || []),
        has_selection: state.selected != nil
      }
    }

    graph = render(f, state, semantic_info)

    init_scene =
      scene
      |> assign(frame: f)
      |> assign(graph: graph)
      |> assign(state: state)
      |> assign(semantic: semantic_info)
      |> push_graph(graph)

    Flamelex.Lib.Utils.PubSub.subscribe(topic: :radix_state_change)

    {:ok, init_scene}
  end

  # TODO handlke frame change

  def handle_info(
        # state variables in pattern match are the same, therefore no state change occured
        {:radix_state_change, %{apps: %{todo_list: state}}},
        %{assigns: %{frame: _f, state: state}} = scene
      ) do
    {:noreply, scene}
  end

  def handle_info(
        {:radix_state_change, %{apps: %{todo_list: new_state}}},
        %{assigns: %{frame: f, state: old_state}} = scene
      ) do
    # # TODO we shouldn't _always_ need to re-render.. should evaluate the changes first
    # diff = MapDiff.diff(scene.assigns.state, new_state)
    # # # IO.inspect(diff)
    # dbg()

    # if old_state.list == new_state.list

    # keep the old scroll
    new_state = put_in(new_state, [:scroll], old_state.scroll)

    # Update semantic info with new state
    semantic_info = scene.assigns[:semantic] || %{}
    updated_semantic = Map.merge(semantic_info, %{
      state: %{
        item_count: length(new_state.list || []),
        has_selection: new_state.selected != nil
      }
    })
    
    new_graph = render(f, new_state, updated_semantic)

    new_scene =
      scene
      |> assign(graph: new_graph)
      |> assign(state: new_state)
      |> assign(semantic: updated_semantic)
      |> push_graph(new_graph)

    {:noreply, new_scene}
  end

  def render(%Widgex.Frame{} = f, %TODOlist.State{} = state, semantic_info \\ nil) do
    [title_frame, tools_frame, list_frame] = calc_layout_frames(f)

    graph = Scenic.Graph.build()
    # Add a nice gradient background
    |> render_background(f)
    # |> Frame.draw_guidewires(args.frame, color: :blue)
    |> render_title(title_frame, "My TODOs")
    |> render_todo_list(list_frame, state)
    # render tools last because it needs to be drawn on top of the app layer due to dropdown menus
    |> render_tools(tools_frame, state)
    |> add_semantic_annotations(semantic_info)
    
    # Render the new TODO dialog if needed
    if state.creating_new_todo? do
      graph |> render_new_todo_dialog(f, state)
    else
      graph
    end
  end

  defp add_semantic_annotations(graph, nil), do: graph
  
  defp add_semantic_annotations(graph, semantic_info) do
    graph
    |> Scenic.Primitives.text("",
      id: {:semantic_todo_list, :main},
      hidden: true,
      semantic: semantic_info
    )
  end

  defp render_background(graph, frame) do
    # Create a nice gradient background
    graph
    |> Scenic.Primitives.rect(
      {frame.size.width, frame.size.height},
      fill: {:linear, {0, 0, 0, frame.size.height, :blue, :dark_slate_blue}},
      translate: frame.pin.point
    )
  end

  def handle_cast({:radix_state_change, new_rdx}, scene) do
    # new_state = Map.merge(scene.assigns.state, %{scroll: new_scroll})
    IO.puts("TODO getting pushed msgs")
    {:noreply, scene}
  end

  def calc_layout_frames(%Frame{} = component_frame) do
    title_frame = calc_title_frame(component_frame)
    tools_frame = calc_tools_frame(component_frame, title_frame)
    list_frame = calc_list_frame(component_frame, title_frame, tools_frame)

    [title_frame, tools_frame, list_frame]
  end

  def calc_title_frame(component_frame) do
    Frame.new(%{
      pin: component_frame.pin.point,
      size: {
        component_frame.size.width,
        0.1 * component_frame.size.height
      }
    })
  end

  def calc_tools_frame(component_frame, title_frame) do
    Frame.new(%{
      pin: {
        component_frame.pin.x,
        component_frame.pin.y + title_frame.size.height
      },
      # temporarily increase the size of this frame so I dont have to solve the dropdown menu box problem yet
      size: {
        component_frame.size.width,
        0.1 * component_frame.size.height
      }
    })
  end

  def calc_list_frame(component_frame, title_frame, tools_frame) do
    # 5 percent margins

    # ten percent of the page going to the title
    # list_frame_h = 0.1 * component_frame.size.height

    # margin = 0.01

    Frame.new(%{
      pin: {
        component_frame.pin.x,
        component_frame.pin.y + title_frame.size.height + tools_frame.size.height
      },
      size: {
        component_frame.size.width,
        0.8 * component_frame.size.height
      }
    })
  end

  def render_title(graph, frame, title) do
    graph
    |> Scenic.Primitives.group(
      fn graph ->
        graph
        # |> Frame.draw_guidewires(frame)
        |> ScenicWidgets.Markup.Header1.draw(%{frame: frame, text: title})

        # |> Scenic.Primitives.rect(frame.size.box, fill: :green)
        #  stroke: {border_stroke, stroke_color},
        #  translate: frame.pin
        # )
        # |> Scenic.Primitives.text(title,
        #   # font: font.name,
        #   font_size: 20,
        #   fill: :black,
        #   # translate: {0, 72}
        #   # translate: {5, font.ascent}
        # )
      end
      # translate: frame.pin.point
      # scissor: frame.size.box
    )
  end

  # %Flamelex.GUI.Component.TODOlist.State{list: []}
  def render_tools(graph, frame, %State{} = s) do
    # the Scene state remembers what the dropdown filter is
    default = s.filter || {:top_priority, 25} # :all

    # TODO this should not "re-render" every single time that I chnge the dropdown !!
    # the component ought to be steady, but we don't re-render, we simply push an update
    # (either that, or, the component is the one that pushes the state change up)

    # upcoming should show 3 columns, today, this month, this quarter, and then optionally 6 months 1 year 5 year 10 years
    #  {"Upcoming", :upcoming},

    graph
    |> Scenic.Primitives.group(
      fn graph ->
        graph
        |> ScenicWidgets.SpareParts.LukesDropDown.add_to_graph(
          {[
            {"Top priority", {:top_priority, 25}},
             {"All", :all},
             {"This week", :this_week},
             {"This month", :this_month},
             #  {"Next month", :next_month},
             #  {"Most urgent", :most_urgent},
             {"Overdue", :overdue},

             {"Newest 20", {:newest, 20}},
             {"Oldest 20", {:oldest, 20}},
             {"Random 20", {:random, 20}},
             {"Needs triage", :needs_triage},
             {"cancelled", :cancelled},
             {"done", :done},
             #  {"By Priority", :priority},
             #  {"Top Ten", :top_ten},
             #  {"Soonest deadline", :soonest},
             #  {"Un-prioritized", :un_prioritized},
             #  {"Done", :done},
           ], default},
          id: :filter_select,
          translate: {20, 20}
        )
        |> ScenicWidgets.SpareParts.LukesMultiSelect.add_to_graph(
          {[
             {"In progress", :in_progress},
             {"Done", :done},
             {"Cancelled", :cancelled}
           ], []},
          id: :status_select,
          translate: {280, 20}
        )
        # Add sort dropdown
        |> ScenicWidgets.SpareParts.LukesDropDown.add_to_graph(
          {[
            {"Default", :default},
            {"Priority (High → Low)", :priority_high},
            {"Priority (Low → High)", :priority_low},
            {"Date (Newest → Oldest)", :date_newest},
            {"Date (Oldest → Newest)", :date_oldest}
          ], s.sort_order || :default},
          id: :sort_select,
          translate: {480, 20}
        )
        |> Scenic.Components.button("Search.....", id: :search_todos, t: {700, 21})
        |> Scenic.Components.button("New TODO", id: :new_todo, t: {900, 21})
      end,
      translate: frame.pin.point
      # scissor: frame.size.box
    )
  end

  # no TODOs to render...
  def render_todo_list(graph, frame, %{list: []}) do
    graph
    |> Scenic.Primitives.group(
      fn graph ->
        graph
        |> Scenic.Primitives.text("No TODOs for this filter",
          font_size: 50,
          font: :ibm_plex_mono,
          fill: :white,
          # translate: {frame.size.width / 2, frame.size.height / 2}
          translate: {72, 172}
        )
      end,
      translate: frame.pin.point
    )
  end

  @todo_height 60
  def render_todo_list(graph, frame, state) do
    # NOTE: it seems tempting apply GUI filters here, but what's supposed to
    # happen is that the radix-reducer is supposed to update the radix state,
    # and we get notified of that, so we really need to remember our job,
    # which is to be a graphical reflection of the radix-state
    todo_widgets =
      state.list
      |> Enum.with_index()
      |> Enum.map(fn {t, index} ->
        {NeoHyperCard,
         %{
           tidbit: t,
           frame:
             Widgex.Frame.new(%{
               size: {frame.size.width, @todo_height},
               pin: {0, @todo_height * index}
             })
         }}
      end)

    graph
    |> Scenic.Primitives.group(
      fn graph ->
        graph
        # |> Frame.draw_guidewires(frame, color: :white)
        |> ScenicWidgets.VerticalList.add_to_graph(%{
          id: VList,
          frame: frame,
          items: todo_widgets,
          scroll: state.scroll
        })
      end,
      # id: TODOlist,
      translate: frame.pin.point
      # scissor: frame.size.box
    )
  end

  # TODO hacky but maybe will work, introduce de-bounding of clicked items here lol
  # if we get 2 clicks in certain number of milliseconds, then we can assume it's a double click
  # this might solve the issue where clicking a menubar item which is hovering over something below it triggers both
  def handle_cast({:click, %Memelex.TidBit{} = t}, %{assigns: %{dropdown_mode: true}} = scene) do
    {:noreply, scene |> assign(dropdown_mode: false)}
  end

  def handle_cast({:click, %Memelex.TidBit{} = t}, scene) do
    Flamelex.Fluxus.action({TODOlist, {:open_todo, t}})
    {:noreply, scene}
  end

  # def handle_cast(
  #       {:cursor_scroll, TODOlist, {{_dx, dy} = delta_scroll, coords}},
  #       %{
  #         assigns: %{state: %{turbo?: true}}
  #       } = scene
  #     ) do
  #   fast_scroll = {0, 100 * dy}

  #   new_scroll =
  #     scene.assigns.scroll
  #     |> Scenic.Math.Vector2.add(delta_scroll)

  #   cast_children(scene, {:set_scroll, new_scroll})
  #   {:noreply, scene |> assign(scroll: new_scroll)}
  # end

  # def handle_cast({:cursor_scroll, TODOlist, {{_dx, dy} = delta_scroll, coords}}, scene) do
  #

  #   new_scroll =
  #     scene.assigns.scroll
  #     |> Scenic.Math.Vector2.add(delta_scroll)

  #   cast_children(scene, {:set_scroll, new_scroll})
  #   {:noreply, scene |> assign(scroll: new_scroll)}
  # end

  def handle_cast({:cursor_scroll, VList, {{_dx, dy}, _coords}}, scene) do
    # TODO consider actually sending this as an action throuigh Fluxus now....

    # TODO debate
    # there is some debate that I should send this scroll up to the top layer,
    # because maybe I dont want to scroll this maybe I want to scroll the whole page or something

    # and that is valid

    # however in this case, right here and now, I dont need to do that, and it's slow
    # and causes problems - I'm currently refactoring the entire way I store state
    # to work around this issue

    # we appreciate your patience in the mean time

    scroll_speed = if scene.assigns.state.turbo_scroll?, do: 100, else: 20

    new_scroll =
      scene.assigns.state.scroll
      |> Scenic.Math.Vector2.add({0, scroll_speed * dy})

    # Flamelex.Fluxus.action({__MODULE__, {:set_scroll, new_scroll}})

    # new_state = Map.merge(scene.assigns.state, %{scroll: new_scroll})
    # {:noreply, scene |> assign(state: new_state)}

    new_state = scene.assigns.state |> put_in([:scroll], new_scroll)

    cast_children(scene, {:set_scroll, new_scroll})
    {:noreply, scene |> assign(state: new_state)}

    # new_graph =
    #   scene.assigns.graph
    #   |> Scenic.Graph.modify(
    #     __MODULE__,
    #     &Scenic.Primitives.update_opts(&1, translate: new_scroll)
    #   )

    # new_state = scene.assigns.state |> put_in([:scroll], new_scroll)

    # new_scene =
    #   scene
    #   |> assign(graph: new_graph)
    #   |> assign(state: new_state)
    #   |> push_graph(new_graph)

    # {:noreply, scene}
  end

  def handle_cast({:focus, _id}, scene) do
    # this is a bit of a hack but basically when the dropdown
    # drops it will msg the todo list (it's parent), we
    # set the whole component into dropdown mode, and in dropdown
    # mode we dont handle clicks from anything except the dropdown
    # - this will hopefully fix the bug ("workaround") where clicking
    # on a dropdown also clicks the item (usually a TODO) below it (in the z plane)
    {:noreply, scene |> assign(dropdown_mode: true)}
  end

  def handle_event({:value_changed, :filter_select, filter_by}, _context, scene) do
    # NOTE: don't need to validate the filter here, because the Reducer will do that
    # TODO _however_, if the reducer fails, nothing crashes but the dropdown remains on the
    # new selection, which causes it to "look" like it worked, but it didn't
    Flamelex.Fluxus.action({TODOlist.Reducer, {:filter_todos, filter_by}})
    {:noreply, scene}
  end
  
  def handle_event({:value_changed, :sort_select, sort_by}, _context, scene) do
    Flamelex.Fluxus.action({TODOlist.Reducer, {:sort_todos, sort_by}})
    {:noreply, scene}
  end

  def handle_event({:btn_pressed, :new_todo}, _context, scene) do
    Flamelex.Fluxus.action({TODOlist, :new_todo})
    {:noreply, scene}
  end

  # def handle_event(e, scene) do
  #   IO.inspect("#{inspect(e)}")
  #   {:noreply, scene}
  # end

  # def handle_info(msg, scene) do
  #   IO.inspect("#{inspect(msg)}")
  #   {:noreply, scene}
  # end

  # @fast_scroll_speed 20
  # def compute_scroll({_x, _y} = current_cumulative_scroll, {_dx, dy}) do
  #   # TODO cap scroll - right now we just dont allow negative scrolling

  #   # speed up scrolling, and we never scroll in x direction (yet)
  #   fast_scroll = {0, @fast_scroll_speed * dy}

  #   new_cumulative_scroll =
  #     current_cumulative_scroll
  #     |> Scenic.Math.Vector2.add(fast_scroll)

  #   case new_cumulative_scroll do
  #     {x, y} when y > 0 ->
  #       # we want to be able to scroll "down" the list but
  #       # not "up" past the starting point, therefore
  #       # we only allow negative y values when scrolling
  #       {x, 0}

  #     {x, y} ->
  #       {x, y}
  #   end
  # end

  defp render_new_todo_dialog(graph, frame, state) do
    # Create a semi-transparent overlay
    overlay_width = frame.size.width
    overlay_height = frame.size.height
    
    # Dialog dimensions
    dialog_width = min(600, overlay_width * 0.8)
    dialog_height = 400
    dialog_x = (overlay_width - dialog_width) / 2
    dialog_y = (overlay_height - dialog_height) / 2
    
    graph
    # Semi-transparent black overlay
    |> Scenic.Primitives.rect(
      {overlay_width, overlay_height},
      fill: {:color_rgba, {0, 0, 0, 180}},
      translate: frame.pin.point,
      input: [:cursor_button],
      id: :todo_dialog_overlay
    )
    # Dialog background
    |> Scenic.Primitives.rect(
      {dialog_width, dialog_height},
      fill: :white,
      stroke: {2, :dark_slate_blue},
      translate: {dialog_x, dialog_y},
      id: :todo_dialog_bg
    )
    # Dialog title
    |> Scenic.Primitives.text(
      "Create New TODO",
      font_size: 24,
      font: :ibm_plex_mono,
      fill: :dark_slate_blue,
      translate: {dialog_x + 20, dialog_y + 40}
    )
    # Title input field
    |> Scenic.Primitives.text(
      "Title:",
      font_size: 16,
      font: :ibm_plex_mono,
      fill: :black,
      translate: {dialog_x + 20, dialog_y + 90}
    )
    |> Scenic.Components.text_field(
      state.new_todo_form.title,
      id: :new_todo_title,
      width: dialog_width - 40,
      height: 35,
      hint: "Enter TODO title...",
      translate: {dialog_x + 20, dialog_y + 100}
    )
    # Description field
    |> Scenic.Primitives.text(
      "Description:",
      font_size: 16,
      font: :ibm_plex_mono,
      fill: :black,
      translate: {dialog_x + 20, dialog_y + 160}
    )
    |> Scenic.Components.text_field(
      state.new_todo_form.description,
      id: :new_todo_description,
      width: dialog_width - 40,
      height: 35,
      hint: "Enter description...",
      translate: {dialog_x + 20, dialog_y + 170}
    )
    # Priority dropdown
    |> Scenic.Primitives.text(
      "Priority:",
      font_size: 16,
      font: :ibm_plex_mono,
      fill: :black,
      translate: {dialog_x + 20, dialog_y + 230}
    )
    |> Scenic.Components.dropdown(
      {[
        {"High", :high},
        {"Medium", :medium},
        {"Low", :low}
      ], state.new_todo_form.priority},
      id: :new_todo_priority,
      translate: {dialog_x + 20, dialog_y + 240}
    )
    # Buttons
    |> Scenic.Components.button(
      "Cancel",
      id: :cancel_new_todo,
      theme: :secondary,
      translate: {dialog_x + dialog_width - 180, dialog_y + dialog_height - 60}
    )
    |> Scenic.Components.button(
      "Create",
      id: :create_new_todo,
      theme: :primary,
      translate: {dialog_x + dialog_width - 90, dialog_y + dialog_height - 60}
    )
  end

  # Handle new TODO dialog events
  def handle_event({:click, :todo_dialog_overlay}, _context, scene) do
    # Close dialog when clicking outside
    Flamelex.Fluxus.action({TODOlist, :cancel_new_todo})
    {:noreply, scene}
  end

  def handle_event({:value_changed, :new_todo_title, value}, _context, scene) do
    Flamelex.Fluxus.action({TODOlist, {:update_new_todo_form, :title, value}})
    {:noreply, scene}
  end

  def handle_event({:value_changed, :new_todo_description, value}, _context, scene) do
    Flamelex.Fluxus.action({TODOlist, {:update_new_todo_form, :description, value}})
    {:noreply, scene}
  end

  def handle_event({:value_changed, :new_todo_priority, value}, _context, scene) do
    Flamelex.Fluxus.action({TODOlist, {:update_new_todo_form, :priority, value}})
    {:noreply, scene}
  end

  def handle_event({:btn_pressed, :cancel_new_todo}, _context, scene) do
    Flamelex.Fluxus.action({TODOlist, :cancel_new_todo})
    {:noreply, scene}
  end

  def handle_event({:btn_pressed, :create_new_todo}, _context, scene) do
    Flamelex.Fluxus.action({TODOlist, :create_todo})
    {:noreply, scene}
  end
end
