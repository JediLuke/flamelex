defmodule Flamelex.GUI.Component.MenuBar do
  @moduledoc """
  This module is responsible for drawing the MenuBar.

  The Menubar displays a tree-like structure of specific functions, enabling
  them to be triggered via the GUI.
  """
  use Flamelex.GUI.ComponentBehaviour

  def height, do: 40

  @left_margin 15
  @tab_width 140

  @impl Flamelex.GUI.ComponentBehaviour
  def render(frame) do
    inactive_menubar(frame)
  end


  @doc """
  This function returns a map which describes all the menu items.
  """
  def menu_buttons_mapping do
    # top-level buttons
    %{
      "Flamelex" => %{},
      "Memex" => %{},
      "GUI" => %{},
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
  def handle_action({graph, frame}, :reset_and_deactivate) do
    {:redraw_graph, inactive_menubar(frame)}
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
  def handle_input({:cursor_pos, {_x, _y}}, _context, state) do

    # tab = calc_tab_hover(x)
    # MenuBar.action({:hover, tab})

    #TODO temporarily, just always hover tab 2...
    MenuBar.action({:hover, 2})

    {:noreply, state}
  end

  def handle_input({:cursor_exit, _unknown_param?}, _context, state) do
    MenuBar.action(:reset_and_deactivate)
    {:noreply, state}
  end

  @impl Flamelex.GUI.ComponentBehaviour
  def handle_input({:cursor_button, {:left, :release, _dunno, _coords}}, _context, state) do
    MenuBar.action(:show_active)
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
    |> render_menu_buttons(frame, menu_buttons_mapping())
    |> Draw.border(frame)
  end

  def active_menubar(frame) do
    Draw.blank_graph()
    |> Draw.background(frame, :blue)
    |> render_menu_buttons(frame, menu_buttons_mapping())
    |> Draw.border(frame)
  end

  def render_menu_buttons(graph, _frame, menu_map) do
    button_list = Map.keys(menu_map)

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
              translate: {140 * offset + @left_margin, 28})

    render_button(new_graph, rest, offset+1)
  end
end
