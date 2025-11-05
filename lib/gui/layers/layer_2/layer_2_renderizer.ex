defmodule Flamelex.GUI.Layers.Layer2.Renderizer do

  # NOTE eventually we should not re-draw everything from scratch each time, but for now,
  # since this component rarely updates, it's fine...

  # I think if I put an :id on the MenuBar component, when we redraw we might start to
  # get errors like "couldn't register a process, name taken" etc, because Scenic doesn't always
  # exit the other process before starting this one (and why should it) - if I really
  # wanted to register that component for some reason, then I would have to change this
  # renderizer to follow the pattern of not simply re-rendering, but checking if that component
  # exists, and if it does exist modifying it in place

  def render(%Widgex.Frame{} = layer_f, layer_state) do
    # Custom theme matching widget workbench configuration
    custom_theme = %{
      # Scenic's dark theme colors
      background: :black,
      text: :white,
      hover_bg: {40, 40, 40},
      hover_text: :white,
      dropdown_bg: :black,
      dropdown_text: :white,
      dropdown_hover_bg: {40, 40, 40},
      dropdown_hover_text: :white,
      border: :light_grey,

      # Custom dimensions for taller menu
      menu_height: 60,
      item_width: 150,
      sub_menu_width: 240,  # 60% wider than main menus (150 * 1.6)
      item_height: 35,  # Slightly taller dropdown items
      padding: 8,

      # Typography
      font: :roboto_mono,
      font_size: 18,  # Larger font for better readability

      # Text Overflow
      text_overflow: :ellipsis,
      max_text_width: 200,  # Wider for sub-menus
      ellipsis_char: "..."
    }

    graph =
      Scenic.Graph.build()
      |> ScenicWidgets.MenuBar.add_to_graph(
        %{
          frame: calc_menubar_frame(layer_f, layer_state),
          menu_map: layer_state.menu_map,
          theme: custom_theme
        }
      )

    graph
  end

  def calc_menubar_frame(layer_f, %{menubar: %{height: menubar_h}}) do
    layer_f
    |> Widgex.Frame.v_split(px: menubar_h)
    |> List.first()
  end
end
