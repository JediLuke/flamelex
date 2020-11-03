defmodule Flamelex.ProjectAliases do
  @moduledoc """
  This module makes it easy to include a whole set of very common aliases
  used throughout Flamelex.
  """

  defmacro __using__(_opts) do
    quote do


      alias Flamelex.{Buffer, GUI}

      alias Flamelex.Memex.Journal
      alias Flamelex.CommandBufr
      # alias Flamelex.Buffer.Command, as: CommandBufr #TODO just rename this everywhere


      alias Flamelex.OmegaMaster #TODO remove
      alias Flamelex.Structs.OmegaState

      # alias Flamelex.Structs.{Buffer} #TODO remove but do we still need it??


      #TODO remove these
      alias Flamelex.Utilities
      alias Flamelex.Utilities.TerminalIO

      alias Flamelex.Utilities.ProcessRegistry

      alias Flamelex.GUI.Structs.{Coordinates, Dimensions, Frame, Layout}
      alias Flamelex.GUI.Utilities.Draw

    end
  end
end
