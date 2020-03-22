defmodule Actions do
  defmacro __using__(_) do
    quote do
      alias Franklin.Actions.{Buffer, CommandBuffer}
      import Actions
    end
  end

  @doc "This function is just a shorthand function for use during Dev."
  def cmd do
    Franklin.Actions.CommandBuffer.activate
  end
end
