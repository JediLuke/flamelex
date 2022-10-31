defmodule Flamelex.GUI.Layers.LayerThree do
   alias ScenicWidgets.Core.Structs.Frame


   @kommander_height 50 #TODO


   def render(%{gui: %{viewport: %{size: {vp_width, vp_height}}}} = radix_state) do

      kommander_frame = ScenicWidgets.Core.Structs.Frame.new(
         pin:  {0, vp_height - @kommander_height},
         size: {vp_width, @kommander_height})

      Scenic.Graph.build()
      |> Flamelex.GUI.Component.Kommander.add_to_graph(%{
          frame: kommander_frame,
          radix_state: radix_state
      })
   end

end