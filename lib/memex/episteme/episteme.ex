defmodule Flamelex.Memex.Episteme do
  #TODO have Episteme modules implement a behaviour/protocol, forcing them
  #to present a description/references/etc

  def description do
    "It means “to know” in Greek. It is related to scientific knowledge.
    Attributes: Universal, invariable, context-independent.  Based on
    general analytical rationality. Epistemology, the study of knowledge,
    is derived from episteme.

    Episteme was viewed by the Greeks as a partner to techné. Plato used
    episteme to denote ‘justified true belief”, in contrast to doxa,
    common belief or opinion.

    In Flamelex, the Episteme module & associated sub-modules are used to
    store facts about the world, in a data-as-code way.
    "
  end

  def references do
    [
      "https://aquileana.wordpress.com/2014/02/01/aristotles-three-types-of-knowledge-in-the-nichomachean-ethics-techne-episteme-and-phronesis/"
    ]
  end
end
