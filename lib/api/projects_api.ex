defmodule Flamelex.API.Projects do

   def close_all do
      fire_projects_action(:close_all)
   end

   def open_flamelex do
      project_dir = File.cwd!
      fire_projects_action({:open_project_directory, project_dir})
   end

   def open_test_tree do
      project_dir = "/Users/luke/workbench/temp/test_tree"
      fire_projects_action({:open_project_directory, project_dir})
   end

   defp fire_projects_action(action) do
      Flamelex.Fluxus.action({
         Flamelex.Fluxus.Reducers.Projects,
         action
      })
   end

end