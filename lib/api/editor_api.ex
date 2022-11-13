defmodule Flamelex.API.Editor do

   def split do
      Flamelex.Fluxus.action({Flamelex.Fluxus.Reducers.Editor, :split_layer_one}) #TODO just hack it for now...
   end

end