defmodule Flamelex.Utils.TextManipulationTools do
  use Flamelex.ProjectAliases
  require Logger

  # https://www.gnu.org/software/guile/manual/html_node/String-Modification.html


  @doc ~S"""
  Backspaces a character in the provided text.

  ## Examples

  iex> import Flamelex.Utils.TextManipulationTools, as: Tools
  iex> t = "Rudenesse it selfe she doth refine, Even like an Alchemist divine"
  iex> Tools.substitution(t)
  {:ok, {:create, "shopping"}}

  """
  # def substitution(text) do

  # end

  # def deletion do

  # end

  # def insertion do

  # end




  def delete(text, :last_character) do
    {backspaced_text, _deleted_text} = text |> String.split_at(-1)
    backspaced_text
  end

end
