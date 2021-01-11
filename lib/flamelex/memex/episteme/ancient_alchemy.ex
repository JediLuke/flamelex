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
        text: "Whatever awakens you to your alchemist is the elixir you need.",
        author: " Iva Kenaz, `Alchemist Awakening`"
      }),
      LiteraryQuote.construct(%{
        text: "You are an alchemist; make gold of that.",
        author: "William Shakespeare"
      }),
      LiteraryQuote.construct(%{
        text: "I got into magic because I got into alchemy. Which I got into because I was into chemistry, which I was learning about because I wanted to get better with botany, which I had taken up studying in an effort to grow some killer weed",
        author: "Drew Hayes, `The Utterly Uninteresting and Unadventurous Tales of Fred, the Vampire Accountant`"
      }),
      LiteraryQuote.construct(%{
        text: "The real alchemy consists in being able to turn gold back again into something else; and that's the secret that most of your friends have lost.",
        author: "Edith Wharton"
      }),
      LiteraryQuote.construct(%{
        text: ~s(The human mind adjusts itself to a certain point of view, and those who have regarded nature from one angle, during a portion of their life, can adopt new ideas only with difficulty.),
        author: "Antoine Lavoisier "
      }),
      LiteraryQuote.construct(%{
        text: ~s(Alchemy, It is the scientific technique of understanding the structure of matter, decomposing it, and then reconstructing it. If performed skillfully, it is even possible to create gold out of lead. However, as it is a science, there are some natural principles in place. Only one thing can be created from something else of a certain mass. This is the Principle of Equivalent Exchange.),
        author: "Fullmetal Alchemist: Brotherhood, Intro"
      }),
      LiteraryQuote.construct(%{
        text: ~s(Perception is the illusion that gives all matter mass),
        author: "A.K. Luthienne, `Flight of the Eagle`"
      }),
      LiteraryQuote.construct(%{
        text: ~s(Alchemy is taking something ordinary and turning it into something extraordinary, sometimes in a way that cannot be explained.),
        author: "Kenneth Coombs, Tarot Alchemy: A Complete Analysis of the Major Arcana"
      }),
      LiteraryQuote.construct(%{
        text: ~s(Language is the alchemy of transforming a thought into a word, and the word into a new reality.),
        author: "Jennifer Sodini"
      }),
      LiteraryQuote.construct(%{
        text: ~s(They who search after the Philosopher's Stone [are] by their own rules obliged to a strict and religious life.),
        author: "Isaac Newton"
      }),
      LiteraryQuote.construct(%{
        text: ~s(As `eval`d, So `apply`d),
        author: "Harold Abelson"
      })
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
