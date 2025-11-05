defmodule Flamelex.GUI.Components.MenuBar do
  @moduledoc """
  MenuBar component for Flamelex.
  This module delegates to the Wrapper which integrates ScenicWidgets.MenuBar.
  """
  
  defdelegate add_to_graph(graph, data, opts \\ []), to: Flamelex.GUI.Components.MenuBar.Wrapper
  
  # Keep legacy functions for compatibility
  defdelegate zero_arity_functions(m), to: Flamelex.GUI.Components.MenuBar.MenuMapMaker
  defdelegate modules_and_zero_arity_functions(m), to: Flamelex.GUI.Components.MenuBar.MenuMapMaker
end