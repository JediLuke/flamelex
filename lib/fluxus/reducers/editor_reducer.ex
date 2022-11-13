defmodule Flamelex.Fluxus.Reducers.Editor do
    @moduledoc false
    use Flamelex.ProjectAliases
    require Logger
 
 
    def process(radix_state, :split_layer_one) do
       new_radix_state = radix_state
       |> put_in([:root, :layers, :one], :split)
 
       {:ok, new_radix_state}
    end
 
 end
   