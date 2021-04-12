defmodule Flamelex.ProjectAliases do
  @moduledoc """
  This module makes it easy to include a whole set of very common aliases
  used throughout Flamelex.
  """

  defmacro __using__(_opts) do
    quote do

      alias Flamelex.API.{Buffer, Kommander, GUI, Memex, Journal}

      alias Flamelex.Utilities.ProcessRegistry #TODO make this Utils.
      alias Flamelex.Utils.PubSub

      alias Flamelex.GUI.Structs.{Coordinates, Dimensions, Frame, Layout}
      alias Flamelex.GUI.Utilities.Draw #TODO this should also be Utils.

    end
  end
end
