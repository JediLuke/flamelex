defmodule Flamelex.Memex.Episteme.AncientAlchemy do
  alias Flamelex.Structs.Memex.LiteraryQuote

  def quotes do
    [
      LiteraryQuote.construct(%{
        text: "The true alchemists do not change lead into gold; they change the world into words.",
        author: "William H. Gass"
      }),
      LiteraryQuote.construct(%{
        text: "One man's “magic” is another man's engineering.",
        author: "Robert A. Heinlein"
      }),
      LiteraryQuote.construct(%{
        text: "There is an alchemy in sorrow. It can be transmuted into wisdom, which, if it does not bring joy, can yet bring happiness.",
        author: "Pearl S. Buck"
      }),
      LiteraryQuote.construct(%{
        text: "The real alchemy is transforming the base self into gold or into spiritual awareness. That's really what new alchemy's all about.",
        author: "Fred Alan Wolf"
      }),
      LiteraryQuote.construct(%{
        text: "Alchemy. The link between the immemorial magic arts and modern science. Humankind's first systematic effort to unlock the secrets of matter by reproducible experiment.",
        author: "John Ciardi"
      }),
      LiteraryQuote.construct(%{
        text: "Alchemy is the art of manipulating life, and consciousness in matter, to help it evolve, or to solve problems of inner disharmonies.",
        author: "Jean Dubuis"
      }),
      LiteraryQuote.construct(%{
        text: "Alchemy is really the secret tradition of the redemption of spirit from matter.",
        author: "Terence McKenna"
      }),
      LiteraryQuote.construct(%{
        text: "You are an alchemist; make gold of that.",
        author: "William Shakespeare"
      }),
      LiteraryQuote.construct(%{
        text: "The real alchemy consists in being able to turn gold back again into something else; and that's the secret that most of your friends have lost.",
        author: "Edith Wharton"
      }),
    ]
  end

  def alchemists do
    [
      %{
        name: "Paracelsus",
        reference: %{
          wikipedia: "https://en.wikipedia.org/wiki/Paracelsus"
        }
      }
    ]
  end

  def references do
    [
      "https://www.wiseoldsayings.com/alchemy-quotes/"
    ]
  end
end
