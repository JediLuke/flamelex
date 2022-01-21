defmodule Flamelex.Fluxus.Reducers.Memex do
    @moduledoc false
    use Flamelex.ProjectAliases
    require Logger
  
    def process(%{mode: :normal} = radix_state, :open_memex) do
        IO.inspect radix_state
        {:ok, radix_state}
    end

end
  