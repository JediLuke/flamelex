defmodule Flamelex.GUI.Layers.LayerThree do
   alias ScenicWidgets.Core.Structs.Frame
   
   @behaviour Flamelex.GUI.Layer.Behaviour

   @kommander_height 50 #TODO


   @impl Flamelex.GUI.Layer.Behaviour
   def calc_state(%{gui: %{viewport: %{size: {vp_width, vp_height}}}}) do

      kommander_frame = ScenicWidgets.Core.Structs.Frame.new(
         pin:  {0, vp_height - @kommander_height},
         size: {vp_width, @kommander_height}
      )

      %{
         frame: kommander_frame
      }
   end


   @impl Flamelex.GUI.Layer.Behaviour
   def render(%{frame: kommander_frame}) do
      radix_state = Flamelex.Fluxus.RadixStore.get()

      Scenic.Graph.build()
      |> Flamelex.GUI.Component.Kommander.add_to_graph(%{
          frame: kommander_frame,
          radix_state: radix_state
      })
   end

end