defmodule Flamelex.ProjectAliases do
  @moduledoc """
  This module makes it easy to include a whole set of very common aliases
  used throughout Flamelex.
  """

  defmacro __using__(_opts) do
    quote do

      alias Flamelex.API.{Buffer, CommandBuffer, GUI, Memex, Journal}

      # alias Flamelex.Structs.OmegaState

      alias Flamelex.Utilities.ProcessRegistry

      # alias Flamelex.Memex.Structs.LiteraryQuote

      alias Flamelex.API.GUI.Structs.{Coordinates, Dimensions, Frame, Layout}
      alias Flamelex.API.GUI.Utilities.Draw

    end
  end
end
