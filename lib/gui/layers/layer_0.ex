defmodule Flamelex.GUI.Layers.LayerZero do
   @behaviour Flamelex.GUI.Layer.Behaviour
   alias Flamelex.GUI.Component.Renseijin


   @impl Flamelex.GUI.Layer.Behaviour
   def calc_state(%{desktop: %{renseijin: state}} = radix_state) do

      # use the same frame as Editor for the Renseijin
      %{framestack: [_menubar_f|editor_f]} =
         ScenicWidgets.Core.Utils.FlexiFrame.calc(
            radix_state.gui.viewport,
            {:standard_rule, linemark: radix_state.menu_bar.height}
         )

      state |> Map.merge(%{frame: hd(editor_f)})
   end


   @impl Flamelex.GUI.Layer.Behaviour
   def render(%{visible?: false}, _radix_state) do
      Scenic.Graph.build()
   end

   def render(%{frame: frame, visible?: true, animate?: animate?}, _radix_state) do
      Scenic.Graph.build()
      |> Renseijin.add_to_graph(%{
         frame: frame,
         animate?: animate?
      })
   end

end