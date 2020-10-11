defmodule Flamelex.Memex.Episteme.ElixirBehaviours do

  def description do
    ~s(Behaviours are the default interface for shared instantiations of
    a thing in Elixir.)
  end

  def sample_behaviour do
    ~s|
    defmodule Sample.ElixirBehaviour do
      @moduledoc false


      defmacro __using__(_params) do
        quote do

          # here you can put any code you want to be automatically
          # included in any module that uses this Sample.ElixirBehaviour
          # e.g. `use Sample.ElixirBehaviour`

        end
      end


      @doc """
      An example callback.

      Simple define the name & type-signature, and all modules which implement/use
      this ElixirBehaviour will be required to implement this function.
      """
      @callback sample_callback() :: atom()

    end
    |
  end

  def references do
    [
      "https://elixir-lang.org/getting-started/typespecs-and-behaviours.html"
    ]
  end
end
