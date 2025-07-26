defmodule Flamelex.GUI.Layers.Layer2.Renderizer do
  @moduledoc """
  Layer 2 Renderizer for Flamelex GUI.
  
  ## MenuBar Integration
  
  This module has been updated to use the integrated ScenicWidgets.MenuBar component
  instead of the original Flamelex MenuBar implementation. The integration provides:
  
  - Enhanced visual design with proper triangle indicators
  - Improved input handling and hover behavior  
  - Grace area support for diagonal mouse movement in sub-menus
  - Better theme integration with Flamelex's dark theme
  
  The MenuBar.Wrapper component handles format conversion and event routing,
  allowing seamless integration while preserving all existing functionality.
  """

  # NOTE eventually we should not re-draw everything from scratch each time, but for now,
  # since this component rarely updates, it's fine...

  # I think if I put an :id on the MenuBar component, when we redraw we might start to
  # get errors like "couldn't register a process, name taken" etc, because Scenic doesn't always
  # exit the other process before starting this one (and why should it) - if I really
  # wanted to register that component for some reason, then I would have to change this
  # renderizer to follow the pattern of not simply re-rendering, but checking if that component
  # exists, and if it does exist modifying it in place

  def render(%Widgex.Frame{} = layer_f, layer_state) do
    rdx = Flamelex.Fluxus.RadixStore.get()
    
    # Build the graph with the integrated ScenicWidgets.MenuBar component
    # This uses the MenuBar.Wrapper which handles format conversion and event routing
    graph =
      Scenic.Graph.build()
      |> Flamelex.GUI.Components.MenuBar.Wrapper.add_to_graph(
        %{
          frame: calc_menubar_frame(layer_f, layer_state),
          menu_map: layer_state.menu_map  # Original Flamelex menu format
        },
        id: :flamelex_menubar
      )
      |> add_memex_env_indicator_component(layer_f, rdx)

    graph
  end

  def calc_menubar_frame(layer_f, %{menubar: %{height: menubar_h}}) do
    layer_f
    |> Widgex.Frame.v_split(px: menubar_h)
    |> List.first()
  end

  # Add memex environment indicator as a proper component (can receive clicks)
  defp add_memex_env_indicator_component(graph, %Widgex.Frame{} = frame, %{memex: %{env: %{name: env_name}}} = _radix_state) when env_name != nil do
    graph
    |> Flamelex.GUI.Components.MemexEnvIndicator.add_to_graph(
      nil,
      id: :memex_env_indicator_component,
      viewport_width: frame.size.width
    )
  end

  # When no memex environment is active, don't add indicator component
  defp add_memex_env_indicator_component(graph, _frame, _radix_state) do
    graph
  end
end
