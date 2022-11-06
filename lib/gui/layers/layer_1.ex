defmodule Flamelex.GUI.Layers.LayerOne do
   # NOTE: Something in here has to be about layouts
   # NOTE: Layer 1 is the primary app layer

   @behaviour Flamelex.GUI.Layer.Behaviour

   @impl Flamelex.GUI.Layer.Behaviour
   def calc_state(radix_state) do

      # calc the editor frame
      %{framestack: [_menubar_f|editor_f]} =
         ScenicWidgets.Core.Utils.FlexiFrame.calc(
            radix_state.gui.viewport,
            {:standard_rule, linemark: radix_state.menu_bar.height}
         )

      %{
         frame: hd(editor_f),
         active_app: radix_state.root.active_app
      }
   end

   @impl Flamelex.GUI.Layer.Behaviour
   def render(%{active_app: :desktop}) do
      Scenic.Graph.build()
   end

   def render(%{active_app: :editor, frame: frame}) do
      radix_state = Flamelex.Fluxus.RadixStore.get()

      Scenic.Graph.build()
      |> QuillEx.GUI.Components.Editor.add_to_graph(%{
         frame: frame,
         radix_state: radix_state,
         app: Flamelex
      })
   end

end