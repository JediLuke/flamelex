defmodule Flamelex.Memex do
  @moduledoc """
  The interface to the Memex.
  """
  use Flamelex.CommonDeclarations

  def list_all() do
    raise "this should list all the Memex entries"
  end

  def note do
    raise "create a new tidbit aka a note"
  end


  def random_quote do
    Enum.random(
         Memex.Episteme.AncientAlchemy.quotes()
      ++ Memex.Episteme.BenjaminFranklin.quotes()
      ++ Memex.Episteme.ProgrammingLanguages.ElixirLang.quotes()
    )
  end
end
