defmodule Franklin.Actions.CommandBuffer do
  @moduledoc """
  Contains all the functions relating to the Command Buffer.
  """
  alias Franklin.Buffer.Manager, as: BufMgr

  def activate do
    GUI.Components.CommandBuffer.action('SHOW_EXECUTE_COMMAND_PROMPT')
  end

  def deactivate do
    GUI.Components.CommandBuffer.action('DEACTIVATE_COMMAND_BUFFER')
  end
end
