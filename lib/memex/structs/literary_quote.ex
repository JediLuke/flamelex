defmodule Flamelex.Structs.Memex.LiteraryQuote do
  @moduledoc """
  A literary quote is a short, often profound or funny, snippet of text.
  Quotes are usually attributed to somebody (the original author may be
  unknown, or incorrect), contain a date, and sometimes further sources.
  """

  defstruct [
    hash: nil,
    text: nil,
    author: nil,
    date: nil,
    sources: []
  ]


  @doc """
  Construct/create/instantiate a new struct, from the given input parameters.
  """
  def construct(params) do
    %__MODULE__{
      text: params.text,
      author: params.author
    }
  end
end
