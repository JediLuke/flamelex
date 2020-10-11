defmodule Flamelex.Memex do
  @moduledoc """
  The interface to the Memex.
  """
  use Flamelex.ProjectAliases

  @doc """
  This function must return the Module name for the Memex.Environment
  being used.
  """
  def default_env do
    Flamelex.Memex.Env.JediLuke
  end

  @doc """
  Look in the memex & return a random %LiteraryQuote{}.

  e.g.

  Memex.random_quote.text
  “One man's “magic” is another man's engineering.”
  """
  def random_quote do
    Enum.random(
         Memex.Episteme.AncientAlchemy.quotes()
      ++ Memex.Episteme.BenjaminFranklin.quotes()
      ++ Memex.Episteme.ProgrammingLanguages.ElixirLang.quotes()
    )
  end
end
