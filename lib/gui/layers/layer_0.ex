defmodule Flamelex.GUI.Layers.LayerZero do
   @behaviour Flamelex.GUI.Layer.Behaviour
   alias Flamelex.GUI.Component.Renseijin


   @impl Flamelex.GUI.Layer.Behaviour
   def calc_state(%{root: %{active_app: :desktop}, desktop: %{renseijin: state}} = radix_state) do

      # use the same frame as Editor for the Renseijin
      %{framestack: [_menubar_f|editor_f]} =
         ScenicWidgets.Core.Utils.FlexiFrame.calc(
            radix_state.gui.viewport,
            {:standard_rule, linemark: radix_state.menu_bar.height}
         )

      state |> Map.merge(%{frame: hd(editor_f)})
   end

   def calc_state(_radix_state) do
      %{visible?: false}
   end


   @impl Flamelex.GUI.Layer.Behaviour
   def render(%{visible?: false}, _radix_state) do
      {:ok, Scenic.Graph.build()}
   end

   def render(renseijin_state = %{frame: frame, visible?: true, animate?: animate?}, %{root: %{active_app: :desktop}, desktop: %{renseijin: %{visible?: true}}}) do
      Process.whereis(Flamelex.GUI.Component.Renseijin)
      |> case do
         nil ->
            {:ok,
               Scenic.Graph.build()
               |> Renseijin.add_to_graph(%{
                  frame: frame,
                  animate?: animate?
               })
            }
         pid when is_pid(pid) ->
            GenServer.cast(pid, {:redraw, renseijin_state})
            :ignore
      end
   end

end