defmodule Flamelex.GUI.Component.AgentHuddle.State do
  @moduledoc """
  State management for the Agent huddle component.
  """

  # use StructAccess  # Temporarily commented due to compilation issues

  defstruct [
    # Define state fields here
    tidbit: nil,
    open_chat?: false,
    open_agent_settings?: false,
    open_agent_five_loop?: false
  ]

  def new do
    %__MODULE__{}
  end
end
