defmodule Flamelex.API.Editor do

   def split do
      Flamelex.Fluxus.action({Flamelex.Fluxus.Reducers.Editor, :split_layer_one}) #TODO just hack it for now...
   end

   def show_explorer do
      Flamelex.Fluxus.action({Flamelex.Fluxus.Reducers.Editor, :show_explorer})
   end

   def hide_explorer do
      Flamelex.Fluxus.action({Flamelex.Fluxus.Reducers.Editor, :hide_explorer})
   end

end