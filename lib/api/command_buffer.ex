defmodule Flamelex.API.CommandBuffer do
  @moduledoc """
  This API module is the interface for all functionality relating to the
  CommandBuffer.
  """
  alias Flamelex.Fluxus.Actions.CommandBufferActions

  @doc """
  Make the CommandBuffer visible, and put us in :command mode.
  """
  def show do
    CommandBufferActions.show()
    |> Flamelex.Fluxus.fire_action()
  end

  @doc """
  Make the CommandBuffer not-visible, and put us in :normal mode.
  """
  def hide do
    CommandBufferActions.hide()
    |> Flamelex.Fluxus.fire_action()
  end

  @doc """
  The difference between this function and hide is that hide simply makes
  the API.CommandBuffer invisible in the GUI, but usually when we want it to go
  away we also want to forget all the state in the CommandBuffer - like
  when you mash escape to go back to :edit mode
  """
  def deactivate do
    [
      CommandBufferActions.clear(),
      CommandBufferActions.hide()
    ]
    |> Flamelex.Fluxus.fire_multiple_actions()
  end


  @doc """
  Resets the text field to an empty string.
  """
  def clear do
    CommandBufferActions.clear()
    |> Flamelex.Fluxus.fire_action()
    # Flamelex.Buffer.Command.clear()
  end

  @doc """
  Send input to the API.CommandBuffer
  """
  def input(x) do
    CommandBufferActions.input(x)
    |> Flamelex.Fluxus.fire_action()
    #   def backspace,             do: GenServer.cast(CmdBuffer, :backspace)
    # Flamelex.Buffer.Command.cast({:input, x})
  end

  @doc """
  Execute the command in the API.CommandBuffer
  """
  def execute do
    CommandBufferActions.execute_contents()
    |> Flamelex.Fluxus.fire_action()
    # Flamelex.Buffer.Command.cast(:execute)
  end
end
