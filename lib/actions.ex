defmodule Actions do
  defmacro __using__(_) do
    quote do
      alias Franklin.Actions.{CommandBuffer}
    end
  end
end
