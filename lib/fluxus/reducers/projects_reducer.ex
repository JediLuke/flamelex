defmodule Flamelex.Fluxus.Reducers.Projects do
   @moduledoc false
   use Flamelex.ProjectAliases
   require Logger

   def process(radix_state, :close_all) do
      new_radix_state = radix_state
      |> put_in([:projects, :open_proj], nil)
      |> put_in([:projects, :proj_list], [])

      {:ok, new_radix_state}
   end

   def process(%{projects: %{open_proj: _open_proj}} = radix_state, {:open_project_directory, project_dir}) do
      new_radix_state = radix_state
      |> put_in([:projects, :open_proj], project_dir)

      #TODO update proj_list

      {:ok, new_radix_state}
   end

 end
   