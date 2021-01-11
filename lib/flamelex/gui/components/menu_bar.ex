defmodule Flamelex.GUI.Component.MenuBar do
  @moduledoc """
  This module is responsible for drawing the MenuBar.

  The Menubar displays a tree-like structure of specific functions, enabling
  them to be triggered via the GUI.
  """
  use Flamelex.GUI.ComponentBehaviour

  import Flamelex.GUI.Utilities.Drawing.MenuBarHelper

  #TODO deprecate these, but also come up eith a better name!!
  @left_margin 15
  @tab_width 190

  def height, do: 40
  def menu_item(:left_margin), do: 15
  def menu_item_width, do: 190


  @impl Flamelex.GUI.ComponentBehaviour
  def render(frame, _params) do
    frame |> inactive_menubar()
  end

  #TODO all of this is hacks... we need to move rego_tag into the behaviour, and this needs to be a behaviour
  def rego_tag(%{ref: %Buf{ref: ref}}) do
    rego_tag(ref)
  end
  def rego_tag(%{ref: aa}) when is_atom(aa) do
    rego_tag(aa)
  end
  def rego_tag(x) do #TODO lol
    {:gui_component, x}
  end

  @doc """
  This function returns a map which describes all the menu items.
  """
  def menu_buttons_mapping do
    # top-level buttons
    %{
      "Flamelex" => %{
        "temet nosce" => {Flamelex, :temet_nosce, []},
        "show cmder" => {Flamelex.API.CommandBuffer, :show, []}
      },
      "Memex" => %{
        "random quote" => {Flamelex.Memex, :random_quote, []},
        "journal" => {Flamelex.Memex.Journal, :now, []}
      },
      "GUI" => %{}, #TODO auto-generate it from the GUI file
      "Buffer" => %{
        "open README" => {Flamelex.Buffer, :open!, []},
        "close" => {Flamelex.Buffer, :close, ["/Users/luke/workbench/elixir/flamelex/README.md"]},
      },
      "DevTools" => %{},
      "Help" => %{},
    }
  end



  ##  handle_input callbacks



  @impl Scenic.Scene
  def handle_input({:cursor_pos, {_x, _y} = coords}, _context, frame) do
    case coords |> hovering_over_item?() do
      {:main_menubar, index} ->
          MenuBar.action({:animate_menu, index})
          {:noreply, frame}
      {:sub_menu, index, sub_index} ->
          MenuBar.action({:animate_menu, index, sub_index})
          {:noreply, frame}
    end
  end

  def handle_input({:cursor_button, {:left, :release, _dunno, coords}}, _context, frame) do
    case coords |> hovering_over_item?() do
      {:main_menubar, _index} ->
          # MenuBar.action({:animate_menu, index})
          {:noreply, frame}
      {:sub_menu, index, sub_index} ->
          MenuBar.action({:call_function, index, sub_index})
          {:noreply, frame}
    end
  end

  def handle_input({:cursor_exit, _some_number}, _context, state) do
    # MenuBar.action(:reset_and_deactivate) #TODO how do we do this then?
    {:noreply, state}
  end


  def handle_input({:cursor_button, {:right, :press, _num?, _coords?}}, _context, state) do
    MenuBar.action(:reset_and_deactivate)
    {:noreply, state}
  end

  def handle_input({:cursor_button, anything_else}, _context, state) do
    # ignore it...
    {:noreply, state}
  end

  def handle_input(unmatched_input, _context, state) do
    {:noreply, state}
  end



  ##  handle_action callbacks


    #NOTE: How to develop a component
  #      Say I want to click on something &


  @impl Flamelex.GUI.ComponentBehaviour
  def handle_action({graph, frame}, {:hover, tab}) do
    {:redraw_graph, graph |> Draw.test_pattern()}
  end

  def handle_action({_graph, frame}, :reset_and_deactivate) do
    {:redraw_graph, inactive_menubar(frame)}
  end

  def handle_action({_graph, frame}, {:call_function, index, sub_index}) do

    {:ok, {key, first_sub_menu}} = MenuBar.menu_buttons_mapping() |> Enum.fetch(index)
    # IO.inspect key, label: "KEY"
    # %{"paracelsize" => {Flamelex, :paracelsize, []}}
    # IO.inspect first_sub_menu
    {:ok, {_key, {m, f, a}}} = first_sub_menu |> Enum.fetch(sub_index)

    # {:ok, {m, f, _a} = MenuBar.menu_buttons_mapping() |> Enum.fetch(index) |> Enum.fetch(sub_index)
    Kernel.apply(m, f, a)
    |> IO.inspect

    {:redraw_graph, inactive_menubar(frame)}
  end

  def handle_action({graph, frame}, {:animate_menu, index}) do
    {:redraw_graph, draw_dropdown_menu(graph, frame, index, _sub_index = 0)}
  end

  def handle_action({graph, frame}, {:animate_menu, index, sub_index}) do
    {:redraw_graph, draw_dropdown_menu(graph, frame, index, sub_index)}
  end

  #NOTE: this last handle_action/2 catches actions that didn't match on one of the above
  def handle_action({_graph, frame}, action) do
    :ignore_action
  end
end
