defmodule Flamelex.Utils.RuntimeTools do
  @moduledoc """
  Some convenience functions for handling some situations during run-time.
  """

  @doc """
  Return the root
  """
  def project_root_dir do
    readme_filepath = File.cwd! <> "/README.md" #NOTE: this only works from the root directory of the Flamelex project...
    if File.exists?(readme_filepath) and readme_filepath =~ "flamelex" do
      # assume we're currently in the flamelex root directory
      File.cwd!
    else
      raise "Could not determine the Flamelex root directory.\n\nMost likely, you need to change your current working directory, to the flamelex git repo."
    end
  end
end
