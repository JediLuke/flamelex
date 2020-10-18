defmodule Flamelex.GUI.Utilities.Drawing.MenuBarHelper do
  alias Flamelex.GUI.Component.MenuBar
  alias Flamelex.GUI.Structs.{Coordinates, Dimensions, Frame, Layout}
  alias Flamelex.GUI.Utilities.Draw


  def inactive_menubar(frame) do
    Draw.blank_graph()
    |> Draw.background(frame, :grey)
    |> render_menu_buttons(frame, MenuBar.menu_buttons_mapping())
    # |> Draw.border(frame)
  end

  # def active_menubar(frame) do
  #   Draw.blank_graph()
  #   |> Draw.background(frame, :blue)
  #   |> render_menu_buttons(frame, menu_buttons_mapping())
  #   |> Draw.border(frame)
  # end

  def draw_dropdown_menu(graph, frame, index, _sub_index) do

    #TODO remove all other dropdowns from the graph too

    details = {frame, MenuBar.menu_item_width(), MenuBar.menu_item(:left_margin)}

    # sub_menu = fetch_submenu(index)

    # graph
    # |> IO.inspect

    inactive_menubar(frame)
    |> draw_menu_highlight(details, index, top_left: {0, 0})
    # |> Draw.border(frame)
  end

  def render_menu_buttons(graph, _frame, menu_map) do
    button_list =
      menu_map
      |> Enum.reduce(_initial_acc = [], fn {key, _val}, acc ->
                       acc ++ [key]
                     end)

    graph
    |> render_button(button_list)
  end

  def draw_menu_highlight(graph, {_frame, item_width, left_margin}, index, top_left: {x, y}) do
    margin = x + item_width * index

    # {:ok, {_key, sub_menu}} =
    #   GUI.Component.MenuBar.menu_buttons_mapping()
    #   |> Enum.fetch(index)

    #TODO real text
    # text = case sub_menu do
    #   %{"paracelsize" => _dc} -> "paracelsize"
    #   %{} -> "lame sauce"
    # end
    # draw_dropdown_menu

    sub_menu = ["liberty", "justice", "for_all", "farts", "popsdicle"]
    # sub_menu = ["liberty"]

    graph
    |> highlight_top_menu_item(index)
    |> draw_sub_menu(sub_menu, {{item_width, left_margin}, {x, y}, margin})

  end

  def highlight_top_menu_item(graph, index) do
    graph
  end


  def draw_sub_menu(graph, menu_list, params) do
    {{item_width, left_margin}, {_x, y}, margin} = params

    height = MenuBar.height()

    {new_graph, _index} =
      Enum.reduce(menu_list, {graph, 0}, fn menu_item, {graph, sub_index} ->
        new_graph =
          graph
          |> Scenic.Primitives.rect({item_width, height}, fill: :white, translate: {margin, y + height + height*sub_index})
          |> Scenic.Primitives.text(menu_item, fill: :red, translate: {left_margin + margin,  y + height + height*sub_index + 24}) #TODO need the 40 cause of text drawing from the bottom... should get it from text but F THAT

        {new_graph, sub_index+1}
      end)

    new_graph
    # graph
    # |> (fn graph ->

    # |> Scenic.Primitives.rect({item_width, 120}, fill: :white, translate: {margin, y + GUI.Component.MenuBar.height()})
    # |> Scenic.Primitives.text(text, font: @ibm_plex_mono, fill: :blue, translate: {left_margin + margin, y + 2*GUI.Component.MenuBar.height()})
  end



  def render_button(graph, button_list, offset \\ 0)
  def render_button(graph, [], _offset), do: graph #NOTE: Base case - no buttons left to render...
  def render_button(graph, [button_text|rest], offset) do

    new_graph =
      graph
      |> Scenic.Primitives.text(
            button_text,
              fill: :black,
              #TODO get this height from good science not a guess
              translate: {MenuBar.menu_item_width() * offset + MenuBar.menu_item(:left_margin), 28})

    render_button(new_graph, rest, offset+1)
  end

  def hovering_over_item?({x, y} = _coords) do
    index = (x |> floor() |> div(MenuBar.menu_item_width()))
    if y <= MenuBar.height() do
      {:main_menubar, index}
    else
      sub_index = (y |> floor() |> div(MenuBar.height()))
      {:sub_menu, index, sub_index}
    end
  end
end
