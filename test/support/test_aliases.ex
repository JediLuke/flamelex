defmodule Flamelex.Test.Support.TestAliases do
  @moduledoc """
  This module makes it easy to include a whole set of very common aliases
  used throughout Flamelex (but specific to testing).
  """

  defmacro __using__(_opts) do
    quote do

      alias Flamelex.Buffer

      # alias Flamelex.{Buffer, GUI, Memex}

      # #TODO remove these
      # alias Flamelex.Utilities
      # alias Flamelex.Utilities.TerminalIO

      # alias Flamelex.GUI.Structs.{Coordinates, Dimensions, Frame, Layout}
      # alias Flamelex.GUI.Utilities.Draw

    end
  end
end
