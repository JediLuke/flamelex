defmodule Franklin.Actions.CommandBuffer do
  @moduledoc """
  Contains all the functions relating to the Command Buffer.
  """
  # alias Franklin.Buffer.Manager, as: BufMgr
  alias GUI.Components.CommandBuffer, as: Component

  def activate do
    Component.action('ACTIVATE_COMMAND_BUFFER_PROMPT')
  end

  def deactivate do
    Component.action('DEACTIVATE_COMMAND_BUFFER')
  end

  def enter_character(char) when is_binary(char) do
    Component.action({'ENTER_CHARACTER', char})
  end
end
