defmodule Flamelex.GUI.Component.MenuBar.Utils do
  alias Flamelex.GUI.Component.MenuBar
  use Flamelex.ProjectAliases
  use Flamelex.GUI.ScenicEventsDefinitions
  require Logger
  @moduledoc """
  This module contains pure-functions to be used by MenuBar.

  Because these are all pure-functions, we can run them with Wormhole,
  and if they crash - nobody cares!
  """

  # don't render anything when there's no menu items to display
  def render(%Scenic.Scene{assigns: %{menu_tree: m}} = scene) when m in [%{}, nil, []] do
    scene |> Draw.clean_slate()      # overwrites scene.assigns.graph with a new %Scenic.Graph{}
  end
  
  # by default, nothing is highlighted
  def render(%Scenic.Scene{assigns: %{
                state: _state,          # we don't need these, I'm just doing
                frame: %Frame{} = _f,   # a little but of pattern-match type-checking ;)
                menu_tree: menu }} = scene) do
    Logger.debug "re-rendering Flamelex.GUI.Component.MenuBar..."
    scene
    |> Draw.clean_slate()         # overwrites scene.assigns.graph with a new %Scenic.Graph{}
    |> Draw.background(:grey)     # looks at scene.assigns.frame, gets dimensions & draws a background
    |> render_menubar(menu)       # Use the menu_bar mappings to render the top-level menu
    |> Draw.border()              # looks at the scene.assigns.frame & draws a border
  end


  ##
  ##  Helpers
  ##


  def render_menubar(%{assigns: %{state: :not_hovering_over_menubar}} = scene, menu_map) do
    scene |> recursively_render_topmenu(Map.keys(menu_map))
  end

  # in this mode, we are highlighting the menu
  def render_menubar(%{assigns: %{state: {:hover, {:main_menubar, index}}}} = scene, menu_map) do
    Logger.debug "rendering the :main_menubar..."
    scene
    |> recursively_render_topmenu(Map.keys(menu_map))
    |> render_submenu(menu_map, index)
  end

  def recursively_render_topmenu(scene, []) do
    scene
  end

  def recursively_render_topmenu(scene, [], _opts) do
    scene
  end

  def recursively_render_topmenu(scene, [_label|_rest] = menu_items) do
    recursively_render_topmenu(scene, menu_items, offset: 0) # offset keeps track of the number of menu items we've already rendered
  end

  # def recursively_render_topmenu(%{assigs: %{state: :not_hovering_over_menubar}} = scene, [label|rest], offset: offset) do
    
  # end

  # def recursively_render_topmenu(scene, [label|rest] = menu_items, hover: hover) do
    
  #   recursively_render_topmenu(scene, menu_items, hover: hover, offset: 0)
  # end


  # def recursively_render_topmenu(scene, [label|rest], hover: hover, offset: offset) do
  #   when hover == offset+1 do
  #     Logger.debug "you're hovering over the offset!"
  # end
  
  # def recursively_render_topmenu(scene, [label|rest], hover: hover, offset: offset) do
  #   new_scene = scene
  #   |> render_topmenu_item(label, hover: hover, offset: offset)

  #   recursively_render_topmenu(new_scene, rest, offset: offset+1)
  # end

  # def recursively_render_topmenu(%{assigs: %{state: {:hover, {:main_menubar, index}}}} = scene, [label|rest], offset: offset)
  #   when index == offset+1 do
  #     Logger.debug "rendering the box we're hovering over! index: #{inspect index}, offset: #{inspect offset}"
  #     Logger.debug "rendering #{label}"
  #     new_scene = scene
  #     |> render_topmenu_item(label, offset: offset)

  #     recursively_render_topmenu(new_scene, rest, offset: offset+1)
  # end

  def recursively_render_topmenu(scene, [label|rest], offset: offset) do
    #Logger.debug "rendering a normal top_menu item #{inspect scene.assigns.state}, offset: #{inspect offset}"
    new_scene = scene
    |> render_topmenu_item(label, offset: offset)

    recursively_render_topmenu(new_scene, rest, offset: offset+1)
  end


  def render_topmenu_item(%{assigns: %{state: {:hover, {:main_menubar, index}}}} = scene, label, offset: offset)
    when index == offset+1 do
      #Logger.debug "rendering a top menu item, WITH hover"
      # the top_left_corner of this menu_item / button
      top_margin = 28 #TODO get this from somewhere real
      box_top_left_corner_coords =
        {MenuBar.menu_item_width() * offset, 0}
      text_top_left_corner_coords =
        {MenuBar.menu_item(:left_margin)+MenuBar.menu_item_width()*offset, top_margin}
      frame = Frame.new(
              top_left_corner: box_top_left_corner_coords,
              dimensions: {MenuBar.menu_item_width(), MenuBar.height()})

      new_graph =
        scene.assigns.graph
        |> Scenic.Primitives.text(
            label,
            # id: {:topmenu_item_text, index},
            fill: :purple,
            font: :ibm_plex_mono,
            translate: text_top_left_corner_coords)
        |> Draw.border_box(frame)

      new_scene = scene
      |> Draw.put_graph(new_graph)
  end

  def render_topmenu_item(scene, label, offset: offset) do
    #Logger.debug "rendering a top menu item, with no hover"
    # the top_left_corner of this menu_item / button
    top_margin = 28 #TODO get this from somewhere real
    box_top_left_corner_coords =
      {MenuBar.menu_item_width() * offset, 0}
    text_top_left_corner_coords =
      {MenuBar.menu_item(:left_margin)+MenuBar.menu_item_width()*offset, top_margin}
    frame = Frame.new(
            top_left_corner: box_top_left_corner_coords,
            dimensions: {MenuBar.menu_item_width(), MenuBar.height()})

    new_graph =
      scene.assigns.graph
      |> Scenic.Primitives.text(
          label,
          # id: {:topmenu_item_text, index},
          fill: :black,
          font: :ibm_plex_mono,
          translate: text_top_left_corner_coords)
      |> Draw.border_box(frame)

    new_scene = scene
    |> Draw.put_graph(new_graph)
  end

  def render_submenu(scene, menu_map, index) do
    Logger.debug "HERE we want to be rendering the sub_menu!"
    scene
  end


  # def render_topmenu_item(scene, label, hover: index, offset: offset)
  #   when index == offset+1 do # render the item currently being hovered over
  #     Logger.debug "rendering the hover box - index: #{inspect index}, offset: #{inspect offset}"
  #     scene
  # end

  # def render_topmenu_item(scene, label, hover: index, offset: offset) do
  #   Logger.debug "rendering a non-hovered menu item - index: #{inspect index}, offset: #{inspect offset}"
  #   # the top_left_corner of this menu_item / button
  #   top_margin = 28 #TODO get this from somewhere real
  #   box_top_left_corner_coords =
  #     {MenuBar.menu_item_width() * offset, 0}
  #   text_top_left_corner_coords =
  #     {MenuBar.menu_item(:left_margin)+MenuBar.menu_item_width()*offset, top_margin}
  #   tile = Frame.new(
  #           top_left_corner: box_top_left_corner_coords,
  #           dimensions: {MenuBar.menu_item_width(), MenuBar.height()})

  #   new_graph =
  #     if offset+1 == index do
  #       scene.assigns.graph
  #       |> Draw.background(tile, :red)
  #       |> Scenic.Primitives.text(
  #           label,
  #           # id: {:topmenu_item_text, index},
  #           fill: :black,
  #           font: :ibm_plex_mono,
  #           translate: text_top_left_corner_coords)
  #       |> Draw.border_box(tile)
  #     else
  #       scene.assigns.graph
  #       |> Scenic.Primitives.text(
  #           label,
  #           # id: {:topmenu_item_text, index},
  #           fill: :black,
  #           font: :ibm_plex_mono,
  #           translate: text_top_left_corner_coords)
  #       |> Draw.border_box(tile)
  #     end

  #   new_scene = scene
  #   |> Draw.put_graph(new_graph)
  # end


      
    # menu_list,
    #                               :horizontal, %{
    #                                 item_dimensions: Dimensions.new()
    #                                 item_width: MenuBar.menu_item_width(), margin: 15}) #TODO get this from right place
    # new_graph = scene.assigns.graph
    # |> recursively_render_menubar_items(menu_map)

    # new_graph = for item <- menu_map do
      
    # end

    # new_graph =
    # graph
    # |> Scenic.Primitives.text(
    #       button_text,
    #         fill: :black,
    #         font: :ibm_plex_mono,
    #         #TODO get this height from good science not a guess
    #         translate: {MenuBar.menu_item_width() * offset + MenuBar.menu_item(:left_margin), 28})


    # %{scene|assigns: scene.assigns |> Map.put(:graph, new_graph)}
    


  # def handle_input(%{assigns: %{state: {:hover, {:main_menubar, index}}}} = scene, {:cursor_pos, {x, y}}) do
  #   if y <= MenuBar.height() do
  #     Logger.debug "now hovering over the menubar..." 
  #     index = (x |> floor() |> div(MenuBar.menu_item_width()))+1 # calc how wide a button is - indexes start at 1 !!
  #     scene |> update_state({:hover, {:main_menubar, index}})
  #   else
  #     scene |> update_state(:not_hovering_over_menubar)
  #   end
  # end

  def handle_input(scene, {:cursor_pos, {x, y}}) do
    if y <= MenuBar.height() do
      #Logger.debug "now hovering over the menubar..."
      index = (x |> floor() |> div(MenuBar.menu_item_width()))+1 # calc how wide a button is - indexes start at 1 !!
      scene |> update_state({:hover, {:main_menubar, index}})
    else
      scene |> update_state(:not_hovering_over_menubar)
    end
  end

  # def handle_input(scene, {:cursor_button, {:btn_left, @click, [], coords}}) do
  # def handle_input(scene, {:cursor_button, {:btn_left, @click, [], coords}}) do
  # def handle_input(scene, {:cursor_button, btn}) do
  def handle_input(%{assigns: %{state: {:hover, {:main_menubar, index}}}} = scene, {:cursor_button, {:btn_left, @click, [], _coords}}) when index == 6 do
    Logger.debug "\n\n We have clicked open memex !!\n\n"
    {:hover, {:main_menubar, index}} = scene.assigns.state # fetch what we're hovering over
    #NOTE - look up the menu, & do that!
    # or, just open the Memex, cause I will dodge it up to do that ;)
    # if index == 6, do: Flamelex.Fluxus.Action.fire(:open_memex) #TODO/note => ok, this is great. We want
    Flamelex.Fluxus.Action.fire(:open_memex) #TODO/note => ok, this is great. We want
                                    # to do something new - so we go ahead,
                                    # and fire that action!! It will just get
                                    # swallowed & ignored, cause we can't handle
                                    # it yet, but now we're on our way to solving that!
    scene
  end

  ## Catch-all!

  def handle_input(scene, input) do
    Logger.warn "ignoring some input... #{inspect input}"
    scene
  end

    # def handle_input(%{assigns: %{state: :not_hovering_over_menubar}} = scene, {:cursor_pos, {x, y}}) do
  #   if y <= MenuBar.height() do
  #     #Logger.debug "now hovering over the menubar..." 
  #     index = (x |> floor() |> div(MenuBar.menu_item_width()))+1 # calc how wide a button is - indexes start at 1 !!
  #     scene |> update_state({:hover, {:main_menubar, index}})
  #   else
  #     Logger.debug "we're not hovering over the menubar..."
  #     # index = (x |> floor() |> div(MenuBar.menu_item_width()))+1 # calc how wide a button is - indexes start at 1 !!
  #     scene
  #   end
  # end

  # def handle_input({:cursor_pos, {_x, _y} = coords} = 
      
  #   # case scene.assigns.graph |> Scenic.Graph.bounds(coords) do
  #   #   true ->
  #   #     Logger.debug "#{__MODULE__} yes we're within bounds."
  #   #   false ->
  #   #     Logger.debug "#{__MODULE__} no we're not within bounds."
  #   # end

  # case coords |> Utils.hovering_over_item?(scene.assigns.state) do
  #   {:main_menubar, index} when index >= 1 ->
  #       Logger.debug "you are hovering over the MenuBar !?"
  #       new_scene =
  #         scene 
  #         |> assign(state: {:hover, {:main_menubar, index}})
  #         |> render_push_graph()
  #       {:noreply, new_scene}
  #   {:sub_menu, index, sub_index} ->
  #       # Flamelex.Fluxus.fire_action({:animate_menu, index, sub_index})
  #       # MenuBar.action()
  #       new_scene =
  #         scene 
  #         |> assign(state: {:hover, {:sub_menu, index, sub_index}})
  #         |> render_push_graph()
  #       {:noreply, scene}
  #   :not_hovering_over_menubar ->
  #       Logger.debug "you are NOT hovering over the MenuBar"
  #       new_scene =
  #         scene |> assign(state: :not_hovering_over_menubar)
  #       {:noreply, new_scene}
  # end




  # def hovering_over_item?({x, y} = _coords, :not_hovering_over_menubar) do
  #   index = (x |> floor() |> div(MenuBar.menu_item_width()))+1 # calc how wide a button is - indexes start at 1 !!
  #   if y <= MenuBar.height() do
  #     Logger.debug "transitioning to :main_menubar mode ->"
  #     {:main_menubar, index}
  #   else
  #     :not_hovering_over_menubar
  #   end
  # end

  # def hovering_over_item?({x, y} = _coords, {:hover, {:main_menubar, index}}) do
  #   if y <= MenuBar.height() do
  #     Logger.debug "we're still hovering over the top menu bar..."
  #     {:hover, {:main_menubar, index}}
  #   else

  #     ##TODO here, we need to calculate if we are hovering over a sub-menu!

  #     # means we're transitioning from hovering over the bar, to either
  #     # a sub-menu, away from the component
  #     :not_hovering_over_menubar
  #   end
  # end


  # def recursively_render_topmenu(graph, textlist, d, config) when d in [:horizontal, :vertical] do
  # def recursively_render_topmenu(graph, textlist, d, config) when d in [:horizontal, :vertical] do

  # end

  # def render(frame, params) do
  #   Logger.debug "rendering a MenuBar I guess..."
  #   frame
  #   |> Draw.background(:grey)
  # end

  # def render(%{assigns: %{frame: %Frame{} = _f}} = scene) do
  #   # We can manually assign some stuff to a %Scenic.Graph{}, there's
  #   # nothing fancy going on under-the-hood.
  #   # https://github.com/boydm/scenic/blob/master/lib/scenic/scene.ex#L404

  #   # 
  #   menubar = render(scene)

  #   new_graph = 
  #     Scenic.Graph.build()


  #   %{scene|assigns: scene.assigns |> Map.put(:graph, value)}
  #   |> render()
  # end


  # def inactive_menubar(%{assigns: %{graph: g, frame: f}} = scene) do
  #   f
  #   |> Draw.background(f, :grey)
  #   |> render_menu_buttons(f, MenuBar.menu_buttons_mapping())
  #   # |> Draw.border(frame)
  # end

  # def active_menubar(frame) do
  #   Draw.blank_graph()
  #   |> Draw.background(frame, :blue)
  #   |> render_menu_buttons(frame, menu_buttons_mapping())
  #   |> Draw.border(frame)
  # end

  # def draw_dropdown_menu(graph, frame, index, sub_index) do

  #   #TODO remove all other dropdowns from the graph too

  #   details = {frame, MenuBar.menu_item_width(), MenuBar.menu_item(:left_margin)}

  #   # sub_menu = fetch_submenu(index)

  #   # graph

  #   # inactive_menubar(frame)
  #   graph
  #   |> draw_menu_highlight(details, index, sub_index, top_left: {0, 0})
  #   # |> Draw.border(frame)
  # end

  # def render_menu_buttons(graph, _frame, menu_map) do
  #   button_list =
  #     menu_map
  #     |> Enum.reduce(_initial_acc = [], fn {key, _val}, acc ->
  #                      acc ++ [key]
  #                    end)

  #   graph
  #   |> render_button(button_list)
  # end

  # def draw_menu_highlight(graph, {_frame, item_width, left_margin}, index, sub_index, top_left: {x, y}) do
  #   margin = x + item_width * index

  #   # {:ok, {_key, sub_menu}} =
  #   #   Flamelex.GUI.Component.MenuBar.menu_buttons_mapping()
  #   #   |> Enum.fetch(index)

  #   #TODO real text
  #   # text = case sub_menu do
  #   #   %{"paracelsize" => _dc} -> "paracelsize"
  #   #   %{} -> "lame sauce"
  #   # end
  #   # draw_dropdown_menu
  #   menu_map = MenuBar.menu_buttons_mapping()
  #   {:ok, {_top_level, sub_menu}} = MenuBar.menu_buttons_mapping() |> Enum.fetch(index)

  #   # sub_menu = ["liberty", "justice", "for_all", "farts", "popsdicle"]
  #   # sub_menu = ["liberty"]
  #   sub_menu = Map.keys(sub_menu)

  #   graph
  #   |> draw_sub_menu(sub_menu, {{item_width, left_margin}, {x, y}, margin}, sub_index)
  #   |> highlight_top_menu_item(index, margin, item_width, y)

  # end

  # def highlight_top_menu_item(graph, index, margin, item_width, y) do
  #   {:ok, {text, %{}}} = MenuBar.menu_buttons_mapping() |> Enum.fetch(index)

  #   graph
  #   |> Scenic.Primitives.rect({item_width, MenuBar.height()}, fill: :dark_blue, translate: {margin, 0})
  #   |> Scenic.Primitives.text(text, font: :ibm_plex_mono, fill: :white, translate: {MenuBar.menu_item(:left_margin) + margin,  MenuBar.height() + 24}) #TODO need the 40 cause of text drawing from the bottom... should get it from text but F THAT
  #   #TODO 28 is correct here but got it through trial & error...
  #   |> Scenic.Primitives.text(text, font: :ibm_plex_mono, fill: :white, translate: {MenuBar.menu_item(:left_margin) + margin, y + 28}) #TODO need the 40 cause of text drawing from the bottom... should get it from text but F THAT
  # end


  # def draw_sub_menu(graph, menu_list, params, highlighted_sub_index) do
  #   {{item_width, left_margin}, {_x, y}, margin} = params

  #   height = MenuBar.height()

  #   {new_graph, _index} =
  #     Enum.reduce(menu_list, {graph, 0}, fn menu_item, {graph, sub_index} ->
  #       color = unless sub_index == highlighted_sub_index, do: :grey, else: :red #TODO this is de way!! re-render buttons conditionally based on highlight

  #       new_graph =
  #         graph
  #         |> Scenic.Primitives.rect({item_width, height}, fill: :white, translate: {margin, y + height + height*sub_index})
  #         |> Scenic.Primitives.text(menu_item, font: :ibm_plex_mono, fill: color, translate: {left_margin + margin,  y + height + height*sub_index + 24}) #TODO need the 40 cause of text drawing from the bottom... should get it from text but F THAT

  #       {new_graph, sub_index+1}
  #     end)

  #   new_graph
  #   # graph
  #   # |> (fn graph ->

  #   # |> Scenic.Primitives.rect({item_width, 120}, fill: :white, translate: {margin, y + Flamelex.GUI.Component.MenuBar.height()})
  #   # |> Scenic.Primitives.text(text, font: :ibm_plex_mono, fill: :blue, translate: {left_margin + margin, y + 2*Flamelex.GUI.Component.MenuBar.height()})
  # end

  # def render_button_list(graph, button_list, offset \\ 0)
  # def render_button(graph, [], _offset), do: graph #NOTE: Base case - no buttons left to render...
  # def render_button(graph, [button_text|rest], offset) do
  # def render_button(graph, [button_text|rest], offset) do


  # def render_button(graph, button_list, offset \\ 0)
  # def render_button(graph, [], _offset), do: graph #NOTE: Base case - no buttons left to render...
  # def render_button(graph, [button_text|rest], offset) do

  #   new_graph =
  #     graph
  #     |> Scenic.Primitives.text(
  #           button_text,
  #             fill: :black,
  #             font: :ibm_plex_mono,
  #             #TODO get this height from good science not a guess
  #             translate: {MenuBar.menu_item_width() * offset + MenuBar.menu_item(:left_margin), 28})

  #   render_button(new_graph, rest, offset+1)
  # end



    # def handle_input({:cursor_button, {:left, :release, _dunno, coords}}, _context, frame) do
  #   case coords |> hovering_over_item?() do
  #     {:main_menubar, _index} ->
  #         # MenuBar.action({:animate_menu, index})
  #         {:noreply, frame}
  #     {:sub_menu, index, sub_index} ->
  #         # MenuBar.action({:call_function, index, sub_index})
  #         {:noreply, frame}
  #   end
  # end

  # def handle_input({:cursor_exit, _some_number}, _context, state) do
  #   # MenuBar.action(:reset_and_deactivate) #TODO how do we do this then?
  #   {:noreply, state}
  # end


  # def handle_input({:cursor_button, {:right, :press, _num?, _coords?}}, _context, state) do
  #   MenuBar.action(:reset_and_deactivate)
  #   {:noreply, state}
  # end

  # def handle_input({:cursor_button, anything_else}, _context, state) do
  #   # ignore it...
  #   {:noreply, state}
  # end

  # def handle_input(unmatched_input, _context, state) do
  #   {:noreply, state}
  # end







  ##  handle_action callbacks


    #NOTE: How to develop a component
  #      Say I want to click on something &


  # @impl Flamelex.GUI.ComponentBehaviour
  # def handle_action({graph, frame}, {:hover, tab}) do
  #   {:redraw_graph, graph |> Draw.test_pattern()}
  # end

  # def handle_action({_graph, frame}, :reset_and_deactivate) do
  #   {:redraw_graph, inactive_menubar(frame)}
  # end

  # def handle_action({_graph, frame}, {:call_function, index, sub_index}) do

  #   {:ok, {key, first_sub_menu}} = MenuBar.menu_buttons_mapping() |> Enum.fetch(index)
  #   # %{"paracelsize" => {Flamelex, :paracelsize, []}}
  #   {:ok, {_key, {m, f, a}}} = first_sub_menu |> Enum.fetch(sub_index)

  #   # {:ok, {m, f, _a} = MenuBar.menu_buttons_mapping() |> Enum.fetch(index) |> Enum.fetch(sub_index)
  #   Kernel.apply(m, f, a)

  #   {:redraw_graph, inactive_menubar(frame)}
  # end

  # # def handle_action({graph, frame}, {:animate_menu, index}) do
  # def handle_action(scene, {:animate_menu, index}) do
  # # def handle_cast({graph, frame}, {:animate_menu, index}) do
  #   {:redraw_graph, draw_dropdown_menu(scene.assigns.graph, scene.assigns.frame, index, _sub_index = 0)}
  # end

  # def handle_action({graph, frame}, {:animate_menu, index, sub_index}) do
  #   {:redraw_graph, draw_dropdown_menu(graph, frame, index, sub_index)}
  # end

  # #NOTE: this last handle_action/2 catches actions that didn't match on one of the above
  # def handle_action({_graph, frame}, action) do
  #   :ignore_action
  # end



  # def highlight_topmenu(scene, index) do
  #   scene
  #   # new_scene = scene
  #   # |> render_topmenu_item(label, index-1) # offsets start at zero :(


  #   # new_graph = scene.assigns.graph
    
  #   # # now, draw highlighted top menu


  #   # # text = Enum.at(menu_map, index+1)
  #   # new_graph = scene.assigns.graph
  #   # |> Scenic.Primitives.text(
  #   #     "Luke",
        
  #   #     fill: :green,
  #   #     font: :ibm_plex_mono,
  #   #     translate: {MenuBar.menu_item_width() * index + MenuBar.menu_item(:left_margin), 28})
  # end


  # def action(a) do
  #   #TODO: We need some way of knowing that MenuBar has indeed been mounted
  #   #      somewhere, or else the messages just go into the void (use call instead of cast?)

  #   #REMINDER: `__MODULE__` will be the module which "uses" this macro
  #   GenServer.cast(__MODULE__, {:action, a})
  # end


      # # def handle_cast({:action, action}, {%Scenic.Graph{} = graph, state}) do
      #   def handle_cast({:action, action}, scene) do
      #     case handle_action(scene, action) do
      #       #TODO this is actually kinda stupid now...
      #       :ignore_action
      #         -> {:noreply, scene}
      #       {:redraw_graph, %Scenic.Graph{} = new_graph}
      #         -> 
      #           new_scene =
      #             scene
      #             |> assign(graph: new_graph)
      #             # |> assign(frame: params.frame)
      #             |> push_graph(new_graph)
                
      #           {:noreply, new_scene}
      #       # {:update_frame, %Frame{} = new_frame}
      #       #   -> {:noreply, {graph, new_frame}}
      #       # {:update_graph_and_state, {%Scenic.Graph{} = new_graph, new_state}}
      #       #   -> 
      #       #     new_scene =
      #       #     scene
      #       #     |> assign(graph: new_graph)
      #       #     # |> assign(frame: params.frame)
      #       #     |> push_graph(new_graph)
              
      #       #   {:noreply, new_scene}
      #       #     {:noreply, {new_graph, new_state}, push: new_graph}
      #       # deprecated_return ->
      #       #   deprecated_return
      #     end
      #   end
    


  # shortcut to overwrite the state of a scene
  defp update_state(%{assigns: assigns} = scene, new_state) do
    %{scene|assigns: assigns |> Map.put(:state, new_state)}
  end


end
