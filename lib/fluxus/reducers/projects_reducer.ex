defmodule Flamelex.Fluxus.Reducers.Projects do
   @moduledoc false
   use Flamelex.ProjectAliases
   require Logger


   def process(%{projects: %{open_proj: nil}} = radix_state, {:open_project_directory, project_dir}) do
      new_radix_state = radix_state
      |> put_in([:projects, :open_proj], project_dir)

      {:ok, new_radix_state}
   end

 end
   