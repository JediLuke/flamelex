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
         layer: 1,
         frame: hd(editor_f),
         active_app: radix_state.root.active_app,
         active_buf: radix_state.editor.active_buf
      }
   end

   @impl Flamelex.GUI.Layer.Behaviour
   def render(%{active_app: :desktop}, _radix_state) do
      {:ok, Scenic.Graph.build()}
   end

   def render(%{active_app: :editor, frame: frame}, radix_state) do
      {:ok,
         Scenic.Graph.build()
         |> QuillEx.GUI.Components.Editor.add_to_graph(%{
            frame: frame,
            radix_state: radix_state,
            app: Flamelex
         })
      }
   end

end