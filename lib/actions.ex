defmodule Franklin.Actions do
  defmacro __using__(_) do
    quote do
      alias Franklin.Actions
      alias Franklin.Buffer
      alias Franklin.CommandBuffer
    end
  end
end
