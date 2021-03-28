defmodule Flamelex.Memex.Episteme.ProgrammingLanguages.ElixirLang do
  alias Flamelex.Structs.Memex.LiteraryQuote

  def quotes do
    [
      LiteraryQuote.construct(%{
        text: "Programming languages are like romantic partners - when you find the one for you, you just know.",
        author: "Luke Taylor"
      })
    ]
  end

  def references do
    []
  end

  def see_also do
    []
  end
end
