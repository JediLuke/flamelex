defmodule Flamelex.GUI.Layers.LayerOne do
   # NOTE: Something in here has to be about layouts

   def render(%{root: %{active_app: :desktop}}) do
      #NOTE: Layer 1 is the primary app layer
      
      # Flamelex.GUI.Renseijin

      Scenic.Graph.build()
   end

   def render(%{root: %{active_app: :editor}} = radix_state) do

      #NOTE: Layer 1 is the primary app layer
      %{framestack: [_menubar_f|editor_f]} =
         ScenicWidgets.Core.Utils.FlexiFrame.calc(
            radix_state.gui.viewport,
            {:standard_rule, linemark: radix_state.menu_bar.height}
         )

      QuillEx.GUI.Components.Editor.render(%{
         frame: hd(editor_f),
         radix_state: radix_state
      })
   end

end