defmodule Flamelex.CommandBufr do
  @moduledoc """
  This module is really just an API of convenience for all this related
  to the CommandBufr.
  """

  @doc """
  Make the CommandBufr visible.
  """
  def show do
    #TODO we should be checking the process is alive or something??
    Flamelex.OmegaMaster.show(:command_buffer)
  end

  @doc """
  The difference between this function and hide is that hide simply makes
  the CommandBufr invisible in the GUI, but usually when we want it to go
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

  def hide do
    Flamelex.OmegaMaster.hide(:command_buffer)
  end

  def input(x) when is_bitstring(x) do
    Flamelex.Buffer.Command.cast({:input, x})
  end

  #   def backspace,             do: GenServer.cast(CmdBuffer, :backspace)
  #   def execute_contents,      do: GenServer.cast(CmdBuffer, :execute_contents)

end
