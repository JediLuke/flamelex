defmodule Flamelex.GUI.Component.MenuBar do
  @moduledoc """
  This module is responsible for drawing the MenuBar.

  The Menubar displays a tree-like structure of specific functions, enabling
  them to be triggered via the GUI.
  """
  use Flamelex.GUI.ComponentBehaviour

  @left_margin 15
  @tab_width 190

  def height, do: 40


  @impl Flamelex.GUI.ComponentBehaviour
  def render(frame, _params) do
    frame |> inactive_menubar()
  end


  @doc """
  This function returns a map which describes all the menu items.
  """
  def menu_buttons_mapping do
    # top-level buttons
    %{
      "Flamelex" => %{
        "paracelsize" => {Flamelex, :paracelsize, []}
      },
      "Memex" => %{
        "random quote" => nil
      },
      "GUI" => %{}, #TODO auto-generate it from the GUI file
      "Buffer" => %{},
      "DevTools" => %{},
      "Help" => %{},
    }
  end


  ##
  ##
  ##  handle_action callbacks
  ##
  ##


  @impl Flamelex.GUI.ComponentBehaviour
  def handle_action({graph, frame}, {:hover, tab}) do

    new_graph =
      graph
      |> Draw.test_pattern()

    {:redraw_graph, new_graph}
  end

  #NOTE: How to develop a component
  #      Say I want to click on something &

  @impl Flamelex.GUI.ComponentBehaviour
  def handle_action({_graph, frame}, :reset_and_deactivate) do
    {:redraw_graph, inactive_menubar(frame)}
  end

  @impl Flamelex.GUI.ComponentBehaviour
  def handle_action({graph, frame}, {:activate, index}) do
    {:redraw_graph, draw_dropdown_menu(graph, frame, index)}
  end

  @impl Flamelex.GUI.ComponentBehaviour
  def handle_action({graph, frame}, action) do
    Logger.debug "#{__MODULE__} with frame: #{inspect frame.id} received unrecognised action: #{inspect action}"
    :ignore_action
  end


  ##
  ##
  ##  handle_input callbacks
  ##
  ##


  @impl Scenic.Scene
  def handle_input({:cursor_pos, {_x, _y} = coords}, _context, frame) do
    case coords |> hovering_over_item?() do
      {:main_menubar, index} ->
          MenuBar.action({:activate, index})
          {:noreply, frame}
      {:sub_menu, index} ->
          MenuBar.action({:animate_sub_menu, index})
          {:noreply, frame}
      _otherwise ->
          MenuBar.action(:reset_and_deactivate)
          {:noreply, frame}
    end
  end

  @impl Flamelex.GUI.ComponentBehaviour
  def handle_input({:cursor_button, {:left, :release, _dunno, _coords}}, _context, state) do
    index = 2 #TODO
    MenuBar.action({:activate, index})
    {:noreply, state}
  end

  @impl Flamelex.GUI.ComponentBehaviour
  def handle_input({:cursor_exit, _some_number}, _context, state) do
    IO.puts "Ecit??"
    # ignore it...
    {:noreply, state}
  end

  @impl Flamelex.GUI.ComponentBehaviour
  def handle_input({:cursor_button, _anything_else}, _context, state) do
    # ignore it...
    {:noreply, state}
  end

  def handle_input(unmatched_input, _context, state) do
    Logger.warn "#{__MODULE__} recv'd unmatched input: #{inspect unmatched_input}"
    {:noreply, state}
  end


  ##
  ##
  ##  private functions
  ##
  ##


  def inactive_menubar(frame) do
    Draw.blank_graph()
    |> Draw.background(frame, :grey)
    # |> render_menu_buttons(frame, menu_buttons_mapping())
    # |> Draw.border(frame)
  end

  # def active_menubar(frame) do
  #   Draw.blank_graph()
  #   |> Draw.background(frame, :blue)
  #   |> render_menu_buttons(frame, menu_buttons_mapping())
  #   |> Draw.border(frame)
  # end

  def draw_dropdown_menu(graph, frame, index) do

    #TODO remove all other dropdowns from the graph too

    details = {frame, @tab_width, @left_margin}

    # sub_menu = fetch_submenu(index)

    graph
    |> Draw.menu_highlight(details, index, top_left: {0, 0})
    |> Draw.border(frame)
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

  def render_button(graph, button_list, offset \\ 0)
  def render_button(graph, [], _offset), do: graph #NOTE: Base case - no buttons left to render...
  def render_button(graph, [button_text|rest], offset) do

    new_graph =
      graph
      |> Scenic.Primitives.text(
            button_text,
              fill: :black,
              #TODO get this height from good science not a guess
              translate: {@tab_width * offset + @left_margin, 28})

    render_button(new_graph, rest, offset+1)
  end

  def hovering_over_item?({x, y} = _coords) do
    if y <= height() do
      index = (x |> floor() |> div(@tab_width))
      {:main_menubar, index}
    else
      false
    end
  end
end
