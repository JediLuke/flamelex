defmodule Flamelex.CommonDeclarations do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do

      alias Flamelex.Memex

      alias Flamelex.OmegaMaster, as: Omega

      alias Flamelex.Structs.{Buffer}

      alias Flamelex.GUI.Structs.{Coordinates, Dimensions, Frame, Layout}
      alias GUI.Utilities.Draw


      #TODO I love having these but we should be able to put them into sub-modules

      defguard is_positive_integer(x)
               when is_integer(x)
               and  x >= 0

      defguard is_positive_float(x)
               when is_float(x)
               and  x >= 0

      #NOTE: Sadly, in macros we can't use recursion over a list of args...
      defguard all_positive_integers(a, b, c, d)
               when is_positive_integer(a)
               and  is_positive_integer(b)
               and  is_positive_integer(c)
               and  is_positive_integer(d)

      defguard all_positive_integers(a, b, c, d, e)
               when all_positive_integers(a, b, c, d)
               and  is_positive_integer(e)

      defguard all_atoms(a, b)
               when is_atom(a)
               and  is_atom(b)

    end
  end
end
