defmodule Flamelex.Fluxus.Reducers.Kommander do
   @moduledoc false
   use Flamelex.ProjectAliases
   require Logger


   def process(radix_state, :show) do
      new_radix_state = radix_state
      |> put_in([:kommander, :hidden?], false)

      {:ok, new_radix_state}
   end

   def process(radix_state, :hide) do
      new_radix_state = radix_state
      |> put_in([:kommander, :hidden?], true)

      {:ok, new_radix_state}
   end

end
  