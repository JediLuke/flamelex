defmodule Flamelex.ProjectAliases do
  @moduledoc """
  This module makes it easy to include a whole set of very common aliases
  used throughout Flamelex.
  """

  defmacro __using__(_opts) do
    quote do

      alias Flamelex.API.{
        Buffer,
        Kommander,
        GUI,
        # Memex
      }

      alias Flamelex.Fluxus
      
      alias Flamelex.GUI.Structs.Coordinates
      alias Flamelex.GUI.Structs.Dimensions
      alias Flamelex.GUI.Structs.Frame
      alias Flamelex.GUI.Structs.Layout
      
      alias Flamelex.GUI.Utils.Draw

      alias Flamelex.Utils.ProcessRegistry
      alias Flamelex.Utils.PubSub

      use IceCream # https://github.com/joseph-lozano/ice_cream

    end
  end
end
