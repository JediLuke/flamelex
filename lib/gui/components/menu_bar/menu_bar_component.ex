defmodule Flamelex.GUI.Component.MenuBar do
  @moduledoc """
  This module is responsible for drawing the MenuBar.

  The Menubar displays a tree-like structure of specific functions, enabling
  them to be triggered via the GUI.
  """
  use Flamelex.GUI.ComponentBehaviour

  def height, do: 40

  @left_margin 15

  @impl Flamelex.GUI.ComponentBehaviour
  def render(frame) do

    Draw.blank_graph()
    |> Draw.background(frame, :grey)
    |> render_menu_buttons(frame, menu_buttons_mapping())
    |> Draw.border(frame)

  end

  @impl Flamelex.GUI.ComponentBehaviour
  def handle_action({state, _graph}, action) do
    Logger.debug "#{__MODULE__} with id: #{inspect state.id} received unrecognised action: #{inspect action}"
    :ignore_action
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
      |> Scenic.Primitives.text(button_text, fill: :black, translate: {140 * offset + @left_margin, 28}) #TODO get this height from good science not a guess

    render_button(new_graph, rest, offset+1)
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
end
