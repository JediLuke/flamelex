defmodule Flamelex.GUI.Layers.LayerThree do
   alias ScenicWidgets.Core.Structs.Frame
   
   @behaviour Flamelex.GUI.Layer.Behaviour

   @kommander_height 50 #TODO


   @impl Flamelex.GUI.Layer.Behaviour
   def calc_state(%{gui: %{viewport: %{size: {vp_width, vp_height}}}}) do

      kommander_frame = ScenicWidgets.Core.Structs.Frame.new(
         pin:  {0, vp_height - @kommander_height},
         size: {vp_width+1, @kommander_height} #TODO why do we need this +1? Without it we see a think black stripe on the right-hand side
      )

      %{
         layer: 3,
         frame: kommander_frame
      }
   end


   @impl Flamelex.GUI.Layer.Behaviour
   def render(%{frame: kommander_frame}, radix_state) do

      {:ok,
         Scenic.Graph.build()
         |> Flamelex.GUI.Component.Kommander.add_to_graph(%{
            frame: kommander_frame,
            radix_state: radix_state
         })
      }
   end

end