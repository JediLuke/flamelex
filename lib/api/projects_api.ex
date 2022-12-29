defmodule Flamelex.API.Projects do

   def open_flamelex do
      project_dir = File.cwd!
      Flamelex.Fluxus.action({
         Flamelex.Fluxus.Reducers.Projects,
         {:open_project_directory, project_dir}
      })
   end

end