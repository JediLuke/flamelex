defmodule Flamelex.API.Memex do
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

  def set_env do
    raise "right now, no way to change your environment unfortuntely"
  end

  def open_catalog do
    #TODO this should open, in a buffer, just like anything else
    raise "the Memex catalog, is the TidlyWiki-like interface to the Memex"
  end

  @doc """
  Look in the memex & return a random %LiteraryQuote{}.
  """
  def random_quote do
    Enum.random(
         Flamelex.Memex.Episteme.AncientAlchemy.quotes()
      ++ Flamelex.Memex.Episteme.BenjaminFranklin.quotes()
      ++ Flamelex.Memex.Episteme.ProgrammingLanguages.ElixirLang.quotes()
    )
  end
end
