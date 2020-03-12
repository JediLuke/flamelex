defmodule Actions do
  defmacro __using__(_) do
    quote do
      alias Franklin.Actions.{Buffer, CommandBuffer}
      import Actions
    end
  end

  def cmd do
    Franklin.Actions.CommandBuffer.activate
  end
end
