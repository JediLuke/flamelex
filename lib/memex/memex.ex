defmodule Flamelex.Memex do
  @moduledoc """
  The interface to the Memex.
  """
  use Flamelex.CommonDeclarations

  def default_env do
    Flamelex.Memex.Env.JediLuke
  end

  def random_quote do
    Enum.random(
         Memex.Episteme.AncientAlchemy.quotes()
      ++ Memex.Episteme.BenjaminFranklin.quotes()
      ++ Memex.Episteme.ProgrammingLanguages.ElixirLang.quotes()
    )
  end
end
