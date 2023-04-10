defmodule Flamelex.Lib.ProjectAliases do
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
        Diary
      }

      alias Memelex.My

      alias Memelex.My.{
        Journal,
        Wiki
      }

      alias Flamelex.Fluxus
      
      alias Flamelex.GUI.Structs.Coordinates
      alias Flamelex.GUI.Structs.Dimensions
      alias Flamelex.GUI.Structs.Layout
      alias ScenicWidgets.Core.Structs.Frame
      
      alias Flamelex.GUI.Utils.Draw

      alias Flamelex.Lib.Utils.ProcessRegistry
      alias Flamelex.Lib.Utils.PubSub

      # use IceCream # https://github.com/joseph-lozano/ice_cream

      import Memelex.Environment, only: [reload_modz: 0]

    end
  end
end
