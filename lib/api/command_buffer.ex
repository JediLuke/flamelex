defmodule Flamelex.API.CommandBuffer do
  @moduledoc """
  This API module is the interface for all functionality relating to the
  CommandBuffer.
  """

  @doc """
  Make the CommandBuffer visible, and put us in :command mode.
  """
  def show do
    Flamelex.OmegaMaster.action({:show, :command_buffer})
  end

  @doc """
  Make the CommandBuffer not-visible, and put us in :normal mode.
  """
  def hide do
    Flamelex.OmegaMaster.action({:hide, :command_buffer})
  end

  @doc """
  The difference between this function and hide is that hide simply makes
  the API.CommandBuffer invisible in the GUI, but usually when we want it to go
  away we also want to forget all the state in the CommandBuffer - like
  when you mash escape to go back to :edit mode
  """
  def deactivate do
    clear()
    hide()
  end


  @doc """
  Resets the text field to an empty string.
  """
  def clear do
    Flamelex.Buffer.Command.clear()
  end

  @doc """
  Send input to the API.CommandBuffer
  """
  def input(x) do
    Flamelex.Buffer.Command.cast({:input, x})
  end

  @doc """
  Execute the command in the API.CommandBuffer
  """
  def execute do
    Flamelex.Buffer.Command.cast(:execute)
  end

  #   def backspace,             do: GenServer.cast(CmdBuffer, :backspace)

end
