defmodule Franklin do

  defmacro __using__(_) do
    quote do
      import Franklin.CLI
    end
  end
end
