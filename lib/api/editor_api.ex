defmodule Flamelex.API.Editor do

   def split do
      Flamelex.Fluxus.action({Flamelex.Fluxus.Reducers.Editor, :split_layer_one}) #TODO just hack it for now...
   end

   def center_view do
      raise "this should move the scroll position to show the line with the cursor in the middle of the screen"
   end

   def hexdocs do
      Flamelex.Fluxus.action({Flamelex.Fluxus.Reducers.Editor, :open_hexdocs}) #TODO just hack it for now...
   end

   def show_explorer do
      Flamelex.Fluxus.action({Flamelex.Fluxus.Reducers.Editor, :show_explorer})
   end

   def hide_explorer do
      Flamelex.Fluxus.action({Flamelex.Fluxus.Reducers.Editor, :hide_explorer})
   end

end